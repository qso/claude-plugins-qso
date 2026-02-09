---
name: x-ai-news-researcher
description: Discover and analyze the latest AI news from X.com (Twitter). Use when the user wants to find AI industry trends, news, model releases, technology breakthroughs, or wants a daily AI news briefing. Triggers include "AI news", "AI动态", "AI新闻", "today in AI", "AI趋势", "what's happening in AI", "X上的AI消息". Do NOT use for general X.com browsing, non-AI topics, or posting tweets.
---

<!-- ============================================================
     STATIC CONTEXT BLOCK — Layer 1 (cacheable, >1024 tokens)
     All instructions, methodology, decision trees, and templates.
     ============================================================ -->

# X AI News Researcher

## Purpose

Discover, curate, and analyze the latest AI news and insights from X.com, then optionally deep-dive into the most significant topics via the deep-research plugin.

**Default output language:** Chinese (Simplified)

## Decision Tree (Execute First)

```
Request Analysis
├─ Simple tweet lookup?           → STOP: Use bird CLI directly
├─ Non-AI topic?                  → STOP: Not applicable for this skill
├─ AI news discovery/analysis?    → CONTINUE
│
Execution Mode
├─ Quick scan (user says "快速扫一眼" / "browse only")
│   → Phases 1-3 only, present analysis, skip deep research
├─ Full workflow (default)
│   → All 6 phases
└─ Deep research only (user provides specific topics)
    → Skip to Phase 5-6
```

---

## 6-Phase Workflow

### Phase 1: FETCH — Data Collection

Invoke the **bird-fetcher** agent via Task tool to collect data from X.com.

**Determine fetch mode based on user input:**
- If user provides **specific topics/keywords** (e.g., "Claude 4", "multimodal agents", "开源大模型") → use **Topic Mode**
- If user has **no specific topic** (general AI news browsing) → use **Default Mode**

**Default Mode — no user topic:**

```
Task(
  subagent_type = "bird-fetcher" (agent),
  prompt = """
  Execute pre-flight checks (install verification + auth check).
  Then fetch these two data sources IN PARALLEL:

  1. AI-curated news with related tweets:
     bird news --with-tweets --tweets-per-item 3 --ai-only -n 20 --json --plain --timeout 30000

  2. Home timeline (For You):
     bird home -n 30 --json --plain --timeout 30000

  Return both JSON results labeled as AI_NEWS_DATA and HOME_TIMELINE_DATA.
  """
)
```

**Topic Mode — user specifies topics of interest:**

```
Task(
  subagent_type = "bird-fetcher" (agent),
  prompt = """
  Execute pre-flight checks (install verification + auth check).
  Then fetch these data sources IN PARALLEL:

  1. AI-curated news with related tweets:
     bird news --with-tweets --tweets-per-item 3 --ai-only -n 20 --json --plain --timeout 30000

  2. Home timeline (For You):
     bird home -n 30 --json --plain --timeout 30000

  3. Targeted search for user topic:
     bird search "<user_topic>" -n 20 --json --plain --timeout 30000

  Return all JSON results labeled as AI_NEWS_DATA, HOME_TIMELINE_DATA, and SEARCH_DATA.
  """
)
```

**Error handling:**
- If bird-fetcher reports auth failure → relay the auth setup instructions to the user, stop workflow.
- If bird-fetcher reports bird not installed → relay installation status to user.
- If one source returns empty but the other succeeds → proceed with available data.
- If both sources return empty → report to user and stop.

---

### Phase 2: SAVE — Working Directory Setup & Raw Data Persistence

**Step 1:** Create working directory:
```bash
timestamp=$(date +%Y%m%d_%H%M%S)
work_dir="${CLAUDE_PROJECT_DIR}/x-ai-news-researcher_result_${timestamp}"
mkdir -p "${work_dir}"
```

**Step 2:** Save AI News data → `${work_dir}/01_raw_ai_news.md`

Format each news item as:
```markdown
## [News Title / Headline]

- **Category**: [category field from bird news]
- **Time**: [timeAgo e.g. "21 hours ago"]
- **Post Count**: [postCount — number of posts about this topic]
- **URL**: [twitter://trending/... URL]

### Summary
[If --with-tweets was used, related tweets will be shown below. Otherwise, this is just the trending headline.]
```

**Note:** `bird news` returns aggregated trending topics, not individual tweets. To get actual tweet content with engagement metrics, use `--with-tweets --tweets-per-item N`. The tweet JSON fields are documented below in the Home Timeline format.

**Step 3:** Save Home Timeline data → `${work_dir}/02_raw_home_timeline.md`

Format each tweet as:
```markdown
## Tweet by @username [Display Name]

- **Tweet ID**: [id]
- **Time**: [createdAt e.g. "Sat Feb 07 23:50:40 +0000 2026"]
- **URL**: https://x.com/@username/status/[id]
- **Engagement**: [likeCount] likes | [retweetCount] RTs | [replyCount] replies
- **Is Retweet**: [Yes if text starts with "RT", else No]
- **Is Reply**: [Yes if replyCount > 0 and not a self-reply, else No]

### Content
[Full text field content]

### Quoted Tweet (if quotedTweet exists)
#### Quoted from @quotedUsername
- **Content**: [quotedTweet.text]
- **Engagement**: [quotedTweet.likeCount] likes | [quotedTweet.retweetCount] RTs
```

**Design note:** AI NEWS and HOME TIMELINE are kept in separate files because they come from different signal sources and carry different baseline quality — Explore news is editorially curated by X, while the home timeline reflects the user's personal network.

**Step 4 (Topic Mode only):** Save Search data → `${work_dir}/02b_raw_search_results.md`

Same format as Home Timeline. Label each entry with the search query that produced it.

---

### Phase 3: ANALYZE — Content Analysis & Filtering

Read `01_raw_ai_news.md` and `02_raw_home_timeline.md`, apply LLM analysis.

#### Content Priority Taxonomy (descending priority)

| Priority | Category | 中文 | Description | Signal Examples |
|----------|----------|------|-------------|-----------------|
| 1 | Industry Observation | 行业观察 | Industry shifts, company strategy, ecosystem changes | Company announcements, partnerships, funding rounds, policy changes, acquisitions |
| 2 | Technical Innovation | 技术创新 | New models, architectures, breakthroughs | Paper releases, benchmark records, new capabilities demo, open-source releases |
| 3 | AI Evaluation | AI评测 | Benchmarks, comparisons, performance analysis | Head-to-head comparisons, real-world test results, user reviews with data |
| 4 | Deep Insight | 深刻认知 | Profound observations, paradigm-level thinking | Thought leadership, contrarian analysis, mental models, industry predictions with reasoning |
| 5 | Technical Tips | 技术技巧 | Practical how-tos, prompting, tools, workflows | Tutorials, prompt engineering, code snippets, tool recommendations with demo |

#### Filtering Rules (MUST filter out)

- **Promotional / Ad tweets**: Sponsored content, product shilling, "use my referral link"
- **Self-promotional hooks**: "Follow me for more...", "Like & RT to help me grow"
- **Engagement farming**: Vague hot takes with no substance, ragebait, "unpopular opinion:" with nothing novel
- **Reposts of old news**: Check recency — if the underlying event is >7 days old, deprioritize
- **Non-AI content**: Content that passed through bird's AI filter but is actually about crypto, general tech drama, or pure memes without AI substance
- **Low-information tweets**: One-line reactions, emoji-only responses, "this is huge" with no elaboration

#### Analysis Output Format (per item)

```markdown
### [Title / Summary — one line]

- **Category**: [行业观察|技术创新|AI评测|深刻认知|技术技巧]
- **Source**: [@username] — [brief description of who they are if notable]
- **Source Type**: [AI News (Explore) | Home Timeline | Search Results]
- **Engagement**: [likeCount] likes | [retweetCount] RTs | [replyCount] replies
- **Tweet URL**: https://x.com/@username/status/[id]
- **Key Insight**: [1-2 sentence summary of WHY this matters]
- **Substance**: [High|Medium] — information density assessment
- **Deep-Dive Potential**: [Yes|No] — whether this warrants in-depth research
```

Save analysis results → `${work_dir}/03_analysis_results.md`

---

### Phase 4: SELECT — Deep-Dive Topic Selection

From the analyzed results, select **up to 3** topics for potential deep research.

#### Selection Methodology (Weighted Scoring)

| Factor | Weight | How to Evaluate |
|--------|--------|-----------------|
| Content Substance | 40% | Actual information density, novelty, depth of the topic. Is there enough to research? |
| Engagement Metrics | 25% | Views, likes, RTs as social proof. High engagement on technical content = strong signal. |
| Publisher Authority | 20% | KOL / major company account / established researcher / verified expert. Weight known voices higher. |
| Timeliness | 15% | Is this breaking news or already widely covered? Prioritize fresh, under-explored angles. |

#### Selection Rules

- **Maximum 3 topics** — if fewer qualify, select fewer. Quality over quantity.
- **Diversity**: Topics should cover different aspects (not 3 variants of the same news).
- **Research-worthiness**: Each topic must have enough substance to warrant a 15+ minute deep research session. Simple announcements that are fully explained in the tweet don't qualify.
- **Topic reframing**: If a tweet is about a paper/product/event, the deep-research topic should be the underlying technology/trend, not the tweet itself. Example: A tweet about "GPT-5 released" → research topic is "GPT-5 architecture, capabilities, and industry impact", not "analysis of @OpenAI's tweet".

Save selections → `${work_dir}/04_deep_dive_candidates.md`

Format:
```markdown
## Deep-Dive Candidate 1: [Topic Title]

- **Original Source**: [@handle] — [tweet URL]
- **Proposed Research Question**: [The actual question to research]
- **Research Type**: [technical | comparison | market | general]
- **Selection Score**: [Overall weighted score]
  - Substance: [score/10]
  - Engagement: [score/10]
  - Authority: [score/10]
  - Timeliness: [score/10]
- **Why This Matters**: [2-3 sentences on why this deserves deep research]
```

---

### Phase 5: PRESENT — User-Facing Summary

Present two sections to the user **in chat** (not to file).

#### Section A: AI 新闻速报

Display all items that passed the analysis filter, organized by priority category:

```
## 🔍 AI 新闻速报 (YYYY-MM-DD)

### 行业观察
1. **[Title]** — [Key insight in one sentence]
   [@source | views/likes/RTs | [Tweet URL]]

2. ...

### 技术创新
1. ...

### AI评测
1. ...

### 深刻认知
1. ...

### 技术技巧
1. ...

---
📊 共发现 N 条有价值的 AI 信息 | 数据来源: X.com AI News + Home Timeline
📁 原始数据已保存至: ${work_dir}/
```

#### Section B: 推荐深研主题

```
## 📌 推荐深入研究的主题

### 1. [Topic Title]
- **原始推文**: [@handle — tweet URL]
- **研究问题**: [Formulated research question]
- **为什么值得深研**: [reasoning — engagement + substance + authority]

### 2. [Topic Title]
...

### 3. [Topic Title]
...

---
是否对以上主题进行深度研究？
- 回复 **"全部研究"** → 并发研究所有主题
- 回复 **"研究 1,3"** → 只研究指定主题
- 回复 **"不需要"** → 结束本次任务
```

**Then use AskUserQuestion tool** to ask user whether to proceed with deep research.

---

### Phase 6: DEEP RESEARCH — Parallel Deep Dives (Conditional)

Only executes if user approves in Phase 5.

#### Step 1: Setup

- Use **TodoWrite** to create tracking checklist for all approved topics.
- Get the current date for folder naming:
  ```bash
  date_str=$(date +%Y%m%d)
  ```

#### Step 2: Parallel Execution via Task Tool

For each approved topic, launch a **Task tool** call with `subagent_type="general-purpose"`:

```
Task(
  subagent_type = "general-purpose",
  description = "Deep research: [topic title]",
  prompt = """
  Execute the deep-research skill on the following research question:

  [Formulated research question from Phase 4]

  Context: This research was triggered by an AI news item from X.com:
  - Original tweet: [URL]
  - Author: [@handle]
  - Key claim/observation: [summary]

  Configuration:
  - Research mode: standard
  - Research type: [technical|comparison|market|general]
  - Output language: Chinese

  IMPORTANT: Override the default project folder. When deep-research initializes its project folder (Phase 2), set:
    project_folder="${work_dir}/${topic_slug}_Research_${date_str}/"
  Do NOT use the default ${CLAUDE_PROJECT_DIR}/${topic_slug}_Research_${date_str}/
  All output files must be saved inside this overridden project folder.

  Work directory to use: ${work_dir}/
  Date string: ${date_str}
  """
)
```

**Parallel execution rules:**
- Launch **up to 3** Task calls in a **single message** for maximum parallelism.
- Track progress via **TodoWrite** — mark each topic as in_progress / completed.
- If a research task fails, report the error but continue with other tasks.

#### Step 3: Post-Research Summary

After all deep research tasks complete, present:

```
## ✅ 深度研究完成

### 研究报告汇总

| # | 主题 | 报告路径 | 状态 |
|---|------|----------|------|
| 1 | [Topic] | ${work_dir}/${topic_slug}_Research_${date_str}/ | ✅ 完成 |
| 2 | [Topic] | ${work_dir}/${topic_slug}_Research_${date_str}/ | ✅ 完成 |
| 3 | [Topic] | ${work_dir}/${topic_slug}_Research_${date_str}/ | ❌ 失败 (原因) |

📁 所有文件保存在: ${work_dir}/
```

**Note:** deep-research creates folders in the format `${topic_slug}_Research_${date}/`. All research reports will be organized as subdirectories under the main work directory.

---

## Error Handling Summary

| Scenario | Action |
|----------|--------|
| bird not installed | Auto-install via `npm install -g @steipete/bird`, retry |
| Cookie auth not configured | Show auth setup guide (env vars / CLI flags / browser cookies), stop |
| bird auth fails (401/403) | Show `bird check` instructions + cookie setup guide, stop |
| bird rate limited (429) | Report, suggest waiting 1-2 min, stop |
| AI News returns empty | Proceed with Home Timeline only |
| Home Timeline returns empty | Proceed with AI News only |
| Both sources empty | Report to user, stop |
| No valuable AI content found | Report honestly — "本次扫描未发现高价值 AI 信息", stop |
| Fewer than 3 deep-dive candidates | Present however many qualify (could be 0-2) |
| deep-research task fails | Report specific failure, continue with other tasks |

---

## Output Directory Contract

```
${CLAUDE_PROJECT_DIR}/x-ai-news-researcher_result_<YYYYMMDD_HHMMSS>/
├── 01_raw_ai_news.md              # Phase 2: Raw AI news from X Explore
├── 02_raw_home_timeline.md        # Phase 2: Raw home timeline data
├── 02b_raw_search_results.md      # Phase 2: Raw search results (Topic Mode only)
├── 03_analysis_results.md         # Phase 3: Analyzed & filtered results
├── 04_deep_dive_candidates.md     # Phase 4: Selected deep-dive topics
├── <topic_slug>_Research_<YYYYMMDD>/   # Phase 6: Deep research report 1 (deep-research naming)
│   ├── research_report_<YYYYMMDD>_<topic_slug>.md
│   ├── research_report_<YYYYMMDD>_<topic_slug>.html
│   └── reference/
├── <topic_slug>_Research_<YYYYMMDD>/   # Phase 6: Deep research report 2
│   └── ...
└── <topic_slug>_Research_<YYYYMMDD>/   # Phase 6: Deep research report 3
    └── ...
```

<!-- End of STATIC CONTEXT BLOCK
     Above content is cacheable (>1024 tokens, static across invocations).
     ============================================================ -->

---

<!-- ============================================================
     DYNAMIC EXECUTION ZONE — Layer 3
     Content below is populated during runtime only.
     ============================================================ -->

## Dynamic Execution Zone

**User Query:**
[User request will be processed here during execution]

**Fetch Results:**
[Bird CLI results will be accumulated here]

**Analysis Results:**
[Filtered and ranked content will be generated here]

**Deep Research Status:**
[Research progress tracking will be maintained here via TodoWrite]
