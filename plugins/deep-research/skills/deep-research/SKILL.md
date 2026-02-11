---
name: deep-research
description: Conduct enterprise-grade research with multi-source synthesis, citation tracking, and verification. Use when user needs comprehensive analysis requiring 10+ sources, verified claims, or comparison of approaches. Triggers include "deep research", "comprehensive analysis", "research report", "compare X vs Y", or "analyze trends". Do NOT use for simple lookups, debugging, or questions answerable with 1-2 searches.
---

# Deep Research

<!-- STATIC CONTEXT BLOCK START - Optimized for prompt caching -->
<!-- All static instructions, methodology, and templates below this line -->
<!-- Dynamic content (user queries, results) added after this block -->

## Core System Instructions

**Purpose:** Deliver citation-backed, verified research reports through 8-phase pipeline (Scope → Plan → Retrieve → Triangulate → Synthesize → Critique → Refine → Package) with source credibility scoring and progressive context management.

**Language Default:** **Chinese (Simplified)**. All reports, summaries, and outputs should be in Chinese by default. Only switch to English if:
- User explicitly requests English output
- Research topic is exclusively English-language content with Chinese readership
- Technical terms are more appropriate in English

**Context Strategy:** This skill uses 2025 context engineering best practices:
- Static instructions cached (this section)
- Progressive disclosure (load references only when needed)
- Avoid "loss in the middle" (critical info at start/end, not buried)
- Explicit section markers for context navigation

---

## Decision Tree (Execute First)

```
Request Analysis
├─ Simple lookup? → STOP: Use WebSearch, not this skill
├─ Debugging? → STOP: Use standard tools, not this skill
└─ Complex analysis needed? → CONTINUE

Mode Selection
├─ Initial exploration? → quick (3 phases, 2-5 min)
├─ Standard research? → standard (6 phases, 5-10 min) [DEFAULT]
├─ Critical decision? → deep (8 phases, 10-20 min)
└─ Comprehensive review? → ultradeep (8+ phases, 20-45 min)

Type Detection → Load [research types](./reference/research_types.md)
├─ Names specific technology/framework? → technical
├─ Contains "vs", "compare", "对比"? → comparison
├─ Market/business/competitor terms? → market
├─ Stock ticker, "股票分析", investment terms? → stock
├─ Broad open-ended question? → exploratory
├─ User explicitly stated type? → Use that type
└─ No match? → general (current behavior unchanged)

Execution Loop (per phase)
├─ Execute phase tasks (see Phase details in Act section)
├─ Spawn parallel agents if applicable
└─ Update progress

Validation Gate
├─ Run `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/validate_report.py --report [path]`
├─ Pass? → Deliver
└─ Fail? → Fix (max 2 attempts) → Still fails? → Escalate
```

---

## Workflow (Clarify → Plan → Act → Verify → Report)

**AUTONOMY PRINCIPLE:** This skill operates independently. Infer assumptions from query context. Only stop for critical errors or incomprehensible queries.

### 1. Clarify (Rarely Needed - Prefer Autonomy)

**DEFAULT: Proceed autonomously. Derive assumptions from query signals.**

**ONLY ask if CRITICALLY ambiguous:**
- Query is incomprehensible (e.g., "research the thing")
- Contradictory requirements (e.g., "quick 50-source ultradeep analysis")

**When in doubt: PROCEED with standard mode. User will redirect if incorrect.**

**Default assumptions:**
- **Language**: Chinese (Simplified) for all reports, unless user requests English
- Technical query → Assume technical audience, type: `technical`
- Comparison query ("vs", "compare") → Assume balanced perspective, type: `comparison`
- Market/business query → Assume business audience, type: `market`
- Broad open-ended query → type: `exploratory`
- Trend query → Assume recent 1-2 years unless specified
- Standard mode and `general` type are defaults for most queries
- See [research types](./reference/research_types.md) for full detection rules

---

### 2. Plan

**Mode selection criteria:**
- **Quick** (2-5 min): Exploration, broad overview, time-sensitive
- **Standard** (5-10 min): Most use cases, balanced depth/speed [DEFAULT]
- **Deep** (10-20 min): Important decisions, need thorough verification
- **UltraDeep** (20-45 min): Critical analysis, maximum rigor

**Announce plan and execute:**
- Briefly state: selected mode, detected type, estimated time, number of sources, language
- Example: "启动标准模式研究，类型: technical (5-10 分钟, 15-30 个来源, 输出语言: 中文)"
- Proceed without waiting for approval

**Initialize project folder (BEFORE Phase 3):**

If the user explicitly specifies an output directory (e.g., "output to /path/to/dir" or provides a `project_folder` path), use that directory directly. Otherwise, use the default naming convention:

```bash
# Extract topic slug and create folder
topic_slug="[clean_topic_name]"  # e.g., "openclaw", "react_vs_vue"
date_str=$(date +%Y%m%d)
folder_name="${topic_slug}_Research_${date_str}"

# If user specified a custom output directory, use it; otherwise use default
# User-specified: project_folder="/custom/path/topic_Research_20260210"
# Default:
project_folder="${CLAUDE_PROJECT_DIR}/${folder_name}"

mkdir -p "${project_folder}"
mkdir -p "${project_folder}/reference"  # For saving valuable sources
echo "Project folder: ${project_folder}"
```

---

### 3. Act (Phase Execution)

**Phase Overview by Mode:**

| Mode | Phases Executed |
|------|----------------|
| Quick | 1 → 3 → 8 |
| Standard | 1 → 2 → 3 → 4 → 4.5 → 5 → 8 |
| Deep | 1 → 2 → 3 → 4 → 4.5 → 5 → 6 → 7 → 8 |
| UltraDeep | 1 → 2 → 3 → 4 → 4.5 → 5 → 6 → 7 → 8 (maximum rigor) |

---

**Phase 1: SCOPE — Research Framing** (All modes)

1. Decompose the question into core components
2. Identify stakeholder perspectives
3. Define scope boundaries (what's in / what's out)
4. Establish success criteria and key assumptions to validate
5. **Detect research type** → Load [research types](./reference/research_types.md) for type detection and search angle filtering

Use extended reasoning (ultrathink) to explore multiple framings before committing to scope.

---

**Phase 2: PLAN — Strategy Formulation** (Standard+)

1. Identify primary and secondary sources
2. Map knowledge dependencies (what must be understood first)
3. Create search query strategy with variants
4. Plan triangulation approach
5. Define quality gates per phase

Branch into multiple potential research paths (Graph-of-Thoughts), then converge on optimal strategy.

---

**Phase 3: RETRIEVE — Parallel Information Gathering** (All modes)

See [Parallel Execution Requirements](#phase-3-retrieve---mandatory-parallel-search) below for detailed instructions.

---

**Phase 4: TRIANGULATE — Cross-Reference Verification** (Standard+)

1. Identify claims requiring verification
2. Cross-reference facts across 3+ independent sources
3. Flag contradictions or uncertainties
4. Assess source credibility (use `${CLAUDE_PLUGIN_ROOT}/scripts/source_evaluator.py`, 0-100 scoring)
5. Note consensus vs. debate areas
6. Document verification status per claim

**Standards:** Core claims must have 3+ independent sources. Flag single-source info. Note recency. Identify potential biases.

---

**Phase 4.5: OUTLINE REFINEMENT — Dynamic Evolution** (Standard+)

After triangulation, compare initial scope with actual discoveries. Adapt outline when evidence warrants.

**Triggers for adaptation** (ANY one triggers refinement):
- Major findings contradict initial assumptions
- Evidence reveals a more important angle than originally scoped
- Critical subtopic emerged that wasn't planned
- Sources consistently discuss aspects not in initial outline

**If adapting:**
- Add sections for important unexpected findings
- Demote/remove sections with insufficient evidence
- Reorder based on evidence strength
- No more than 50% restructuring (if more, scope was severely wrong)

**If major gaps found:** Launch 2-3 targeted searches (not full Phase 3 restart), time-box to 2-5 min.

**Anti-patterns:** Don't adapt based on speculation. Don't add sections without supporting evidence. Don't abandon original research question.

---

**Phase 5: SYNTHESIZE — Deep Analysis** (Standard+)

1. Identify patterns across sources
2. Map relationships between concepts
3. Generate insights beyond source material (novel connections)
4. Create conceptual frameworks
5. Build argument structures with evidence hierarchies

Use extended reasoning to explore non-obvious connections and second-order implications.

---

**Phase 6: CRITIQUE — Quality Assurance** (Deep+)

1. Review for logical consistency
2. Check citation completeness
3. Identify gaps or weaknesses
4. Assess balance and objectivity
5. Test alternative interpretations

**Red Team Questions:** What's missing? What could be wrong? What alternative explanations exist? What biases might be present? What counterfactuals should be considered?

---

**Phase 7: REFINE — Iterative Improvement** (Deep+)

1. Conduct additional targeted research for identified gaps
2. Strengthen weak arguments with additional evidence
3. Add missing perspectives
4. Resolve contradictions found in critique
5. Verify revised content against sources

---

**Phase 8: PACKAGE — Report Generation** (All modes)

See [Report section](#5-report) below for progressive file assembly, HTML generation, and delivery instructions.

---

**Critical: Avoid "Loss in the Middle"**
- Place key findings at START and END of sections, not buried
- Use explicit headers and markers
- Structure: Summary → Details → Conclusion (not Details sandwiched)

**Progressive Context Loading:**
- Load [research types](./reference/research_types.md) in Phase 1 for type detection and search angle filtering
- Load type-specific templates in Phase 8 only — see [research_types.md](./reference/research_types.md#template-routing) for routing
- Do not inline everything for external references - load on-demand

**Anti-Hallucination Protocol (CRITICAL):**
- Every factual claim MUST cite a specific source immediately [N]
- Distinguish FACTS (from sources) from SYNTHESIS (your analysis)
- If unsure whether source says X, do NOT fabricate citation — say "No sources found for X"
- See [Source Attribution Standards](#source-attribution-standards) in Content Requirements for detailed rules

**Parallel Execution Requirements (CRITICAL for Speed):**

**Phase 3 RETRIEVE - Mandatory Parallel Search:**

**8 Canonical Search Angles** (filter by type per [research_types.md](./reference/research_types.md#search-angles-per-type)):
1. Core topic (semantic)
2. Technical details (keyword)
3. Recent developments (2024-2026)
4. Academic sources
5. Alternative perspectives
6. Statistical/data sources
7. Industry analysis
8. Critical analysis/limitations

**Search Tools — Priority & Fallback Strategy:**

优先使用内置搜索和通用 MCP 工具，仅在主要工具失败或结果不足时降级到 Exa MCP。

| 优先级 | 工具 | 用途 | 可用条件 |
|:-------|:-----|:-----|:---------|
| **P0 — 首选搜索** | `WebSearch` | 通用 Web 搜索，获取搜索结果摘要 | 始终可用（内置） |
| **P0 — 首选抓取** | `WebFetch` | 抓取指定 URL 页面内容并提取信息 | 始终可用（内置） |
| **P1 — Exa 搜索** | `mcp__exa__web_search_exa` | Exa 通用 Web 搜索，获取干净可用内容 | 需要 `EXA_API_KEY` 环境变量 |
| **P1 — Exa 高级** | `mcp__exa__web_search_advanced_exa` | Exa 高级搜索（域名/日期/内容过滤） | 需要 `EXA_API_KEY` 环境变量 |
| **P1 — Exa 抓取** | `mcp__exa__crawling_exa` | 从已知 URL 获取完整网页内容 | 需要 `EXA_API_KEY` 环境变量 |
| **P2 — Metaso 搜索** | `mcp__mcp-metaso__metaso_search` | 秘塔搜索（支持网页/文库/学术/图片/视频/播客） | MCP 已配置时可用 |
| **P2 — Metaso 抓取** | `mcp__mcp-metaso__metaso_reader` | 解析网页内容并提取文本 | MCP 已配置时可用 |

**Fallback 降级规则:**
1. **首先**尝试 P0 工具（`WebSearch` + `WebFetch`），这些始终可用
2. **同时**使用可用的 P1 MCP 工具以获取多样化结果（并行调用提高效率）
3. **仅当 P0/P1 工具失败、返回结果不足**，降级使用 P2 MCP 工具
4. Exa 特有优势场景（优先直接使用）：代码搜索用 `mcp__exa__get_code_context_exa`，企业调研用 `mcp__exa__company_research_exa`

**Exa MCP 依赖:** 需要 `EXA_API_KEY` 环境变量。若未设置则跳过所有 P2 工具，仅使用 P0/P1 完成搜索。

**Execution Steps:**
1. Filter angles by research type
2. Decompose into 5-10 independent queries
3. Assign to optimal tools — 同一搜索角度使用多个不同工具以获取多样化结果（如 `WebSearch` + `mcp__exa__web_search_exa` + ``）
4. **Launch ALL in single message** (parallel, NOT sequential)
5. **Fallback check:** 如果 P0/P1 工具返回结果不足（<5 条有效结果），立即使用 P2 Exa 工具补充搜索
6. Monitor quality thresholds:
   - Quick: 10+ sources, >60/100 OR 2min
   - Standard: 15+ sources, >60/100 OR 5min
   - Deep: 25+ sources, >70/100 OR 10min
   - UltraDeep: 30+ sources, >75/100 OR 15min
7. Spawn 3-5 parallel agents for deep-dives
8. **Save valuable sources** to `${project_folder}/reference/`:
   - For sources with credibility >70/100, use `WebFetch`（首选）或`mcp__web-reader__webReader`（备选）to fetch full content
   - Save as `reference/[N]_[slug].md` with title, URL, credibility, content, key insights
   - These will be loaded in Phase 8.0 for detailed report generation

**Requirements:**
- Minimum 3 source types (academic, industry, news, docs)
- Temporal diversity (recent + foundational)
- Perspective diversity (proponents + critics + neutral)
- Score sources 0-100; flag <40 for extra verification

---

### 4. Verify (Always Execute)

**Step 1: Citation Verification (Catches Fabricated Sources)**

```bash
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/verify_citations.py --report [path]
```

**Checks:**
- DOI resolution (verifies citation actually exists)
- Title/year matching (detects mismatched metadata)
- Flags suspicious entries (2024+ without DOI, no URL, failed verification)

**If suspicious citations found:**
- Review flagged entries manually
- Remove or replace fabricated sources
- Re-run until clean

**Step 2: Structure & Quality Validation**

```bash
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/validate_report.py --report [path]
```

**8 automated checks:**
1. Executive summary length (50-250 words)
2. Required sections present (+ recommended: Claims table, Counterevidence)
3. Citations formatted [1], [2], [3]
4. Bibliography matches citations
5. No placeholder text (TBD, TODO)
6. Word count reasonable (500-10000)
7. Minimum 10 sources
8. No broken internal links

**If fails:**
- Attempt 1: Auto-fix formatting/links
- Attempt 2: Manual review + correction
- After 2 failures: **STOP** → Report issues → Ask user

---

### 5. Report

**CRITICAL: Generate COMPREHENSIVE, DETAILED markdown reports**

**File Organization (CRITICAL - Clean Accessibility):**

**Directory Structure:**
```
${CLAUDE_PROJECT_DIR}/                          # Claude Code 运行目录（当前项目）
└── ${project_folder}/                         # = ${CLAUDE_PROJECT_DIR}/${topic_slug}_Research_${date}/
    ├── research_report_${date}_${slug}.md     # Markdown 报告
    ├── research_report_${date}_${slug}.html   # HTML 报告
    ├── research_report_${date}_${slug}.pdf    # PDF 报告（可选）
    └── reference/                             # 参考资料（Phase 3 保存）
        ├── 001_source_title.md
        ├── 002_source_title.md
        └── ...
```

**Where variables are defined:**
- `${CLAUDE_PROJECT_DIR}` = Claude Code 当前运行目录
- `${topic_slug}` = 从研究问题提取的简洁名称（如 "openclaw", "react_vs_vue"）
- `${date}` = YYYYMMDD 格式日期
- `${project_folder}` = `${CLAUDE_PROJECT_DIR}/${topic_slug}_Research_${date}/`（在 Phase 2 初始化）

**2. Save All Formats to Same Folder:**

**Markdown (Primary Source):**
- Save to: `${project_folder}/research_report_[YYYYMMDD]_[topic_slug].md`
- Full detailed report with all findings

**HTML (ALWAYS GENERATE - Template by Research Type):**
- Save to: `${project_folder}/research_report_[YYYYMMDD]_[topic_slug].html`
- **Select HTML template based on research type** — see [research_types.md](./reference/research_types.md#html-templates-visual-presentation) for routing table
- OPEN in browser automatically after generation

**PDF (OPTIONAL - Only when user explicitly requests):**
- Save to: `${project_folder}/research_report_[YYYYMMDD]_[topic_slug].pdf`
- Use generating-pdf skill (via Task tool with general-purpose agent)
- Professional formatting with headers, page numbers
- OPEN in default PDF viewer after generation
- **Do NOT generate PDF unless the user asks for it**

**Reference Materials (Phase 3 - During Research):**
- Folder created in Phase 2: `${project_folder}/reference/`
- Save valuable sources (credibility >70/100) as `reference/[N]_[slug].md`
- Include: title, URL, credibility score, full content, key insights
- **Purpose**: Preserve important details without bloating research context
- **Usage**: Load during Phase 8.0 before report generation

**3. File Naming Convention:**
All files use same base name for easy matching:
- `research_report_20251104_psilocybin_2025.md`
- `research_report_20251104_psilocybin_2025.html`
- `research_report_20251104_psilocybin_2025.pdf` (only if user requests PDF)
- `reference/001_openclaw_architecture.md` (reference materials)
- `reference/002_performance_benchmarks.md` (reference materials)

**Length Requirements (UNLIMITED with Progressive Assembly):**
- Quick mode: 2,000+ words (baseline quality threshold)
- Standard mode: 4,000+ words (comprehensive analysis)
- Deep mode: 6,000+ words (thorough investigation)
- UltraDeep mode: 10,000-50,000+ words (NO UPPER LIMIT - as comprehensive as evidence warrants)

**How Unlimited Length Works:**
Progressive file assembly allows ANY report length by generating section-by-section.
Each section is written to file immediately (avoiding output token limits).
Complex topics with many findings? Generate 20, 30, 50+ findings - no constraint!

**Content Requirements:**
- **Language:** Write reports in **Chinese (Simplified)** by default. Use English only if user explicitly requests or for technical terms without good Chinese equivalents.
- **Report structure by type:** Load the type-specific MD template per [research_types.md](./reference/research_types.md#template-routing) routing table
- Bibliography and Methodology sections are always required regardless of type
- Generate each section to APPROPRIATE depth (determined by evidence, not word targets)
- Include specific data, statistics, dates, numbers (not vague statements)
- Multiple paragraphs per finding with evidence (as many as needed)
- Each section gets focused generation attention
- DO NOT write summaries - write FULL analysis

**Writing Standards:**
- **Language**: Write in Chinese (Simplified) with professional, clear prose. Use appropriate technical terms in English when needed.
- **Narrative-driven**: Write in flowing prose. Each finding tells a story with beginning (context), middle (evidence), end (implications)
- **Precision**: Every word deliberately chosen, carries intention
- **Economy**: No fluff, eliminate fancy grammar, unnecessary modifiers
- **Clarity**: Exact numbers embedded in sentences ("研究显示死亡率降低了 23%"), not isolated in bullets
- **Directness**: State findings without embellishment
- **High signal-to-noise**: Dense information, respect reader's time

**Bullet Point Policy (Anti-Fatigue Enforcement):**
- Use bullets SPARINGLY: Only for distinct lists (product names, company roster, enumerated steps)
- NEVER use bullets as primary content delivery - they fragment thinking
- Each findings section requires substantive prose paragraphs (3-5+ paragraphs minimum)
- Example: Instead of "• 市场规模: $2.4B" write "2023 年全球市场规模达到 24 亿美元，受消费者需求增长和监管政策推动 [1]."

**Anti-Fatigue Quality Check (Apply to EVERY Section):**
Before considering a section complete, verify:
- [ ] **Paragraph count**: ≥3 paragraphs for major sections (## headings)
- [ ] **Prose-first**: <20% of content is bullet points (≥80% must be flowing prose)
- [ ] **No placeholders**: Zero instances of "Content continues", "Due to length", "[Sections X-Y]"
- [ ] **Evidence-rich**: Specific data points, statistics, quotes (not vague statements)
- [ ] **Citation density**: Major claims cited within same sentence

**If ANY check fails:** Regenerate the section before moving to next.

**Source Attribution Standards (Critical for Preventing Fabrication):**
- **Immediate citation**: Every factual claim followed by [N] citation in same sentence
- **Quote sources directly**: Use "根据 [1]..." or "[1] 报道..." for factual statements
- **Distinguish fact from synthesis**:
  - ✅ GOOD: "治疗组死亡率降低 23%（p<0.01）[1]."
  - ❌ BAD: "研究表明死亡率显著改善。"
- **No vague attributions**:
  - ❌ NEVER: "研究表明...", "研究显示...", "专家认为..."
  - ✅ ALWAYS: "Smith 等人 (2024) 发现..." [1], "根据 FDA 数据..." [2]
- **Label speculation explicitly**:
  - ✅ GOOD: "这提示了一种潜在机制..." (analysis, not fact)
  - ❌ BAD: "该机制是..." (presented as fact without citation)
- **Admit uncertainty**:
  - ✅ GOOD: "未找到直接讨论 X 的来源。"
  - ❌ BAD: Fabricating a citation to fill the gap
- **Template pattern**: "[具体声明和数据] [引用]. [分析/影响]."

**Deliver to user:**
1. Executive summary (inline in chat)
2. Organized folder path (e.g., "All files saved to: ${project_folder}")
3. Confirmation of formats generated:
   - Markdown (source)
   - HTML (type-specific template, opened in browser)
   - PDF (only if user requested)
4. Source quality assessment summary (source count)
5. Next steps (if relevant)

**Generation Workflow: Progressive File Assembly (Unlimited Length)**

**Phase 8.0: Load Reference Materials (CRITICAL)**

Before generating the report, load all saved reference materials for detailed context:

```bash
# Reference folder was created in Phase 2: ${project_folder}/reference/
# Load all saved reference files
ls -1 "${project_folder}/reference/"*.md 2>/dev/null || echo "No reference files found"
```

**Loading strategy:**
- Read all reference markdown files in `${project_folder}/reference/`
- Extract key insights, statistics, and important details
- Cross-reference with citation numbers used in the research
- Use this detailed context to enrich report content with specific evidence
- This avoids context bloat during research while preserving important details

**What to extract from each reference:**
1. Key quantitative data and statistics
2. Important technical details or specifications
3. Direct quotes and evidence
4. Methodology information
5. Comparison data
6. Limitations or caveats mentioned

**Phase 8.1: Setup**
```bash
# Reference folder already created in Phase 2
# Create initial markdown file with frontmatter
# File path: ${project_folder}/research_report_[YYYYMMDD]_[slug].md
```

**Phase 8.2: Progressive Section Generation**

**CRITICAL STRATEGY:** Generate and write each section individually to file using Write/Edit tools.
This allows unlimited report length while keeping each generation manageable.

**OUTPUT TOKEN LIMIT SAFEGUARD (CRITICAL - Claude Code Default: 32K):**

Claude Code default limit: 32,000 output tokens (≈24,000 words total per skill execution)
This is a HARD LIMIT and cannot be changed within the skill.

**What this means:**
- Total output (your text + all tool call content) must be <32,000 tokens
- 32,000 tokens ≈ 24,000 words max
- Leave safety margin: Target ≤20,000 words total output

**Realistic report sizes per mode:**
- Quick mode: 2,000-4,000 words ✅ (well under limit)
- Standard mode: 4,000-8,000 words ✅ (comfortably under limit)
- Deep mode: 8,000-15,000 words ✅ (achievable with care)
- UltraDeep mode: 15,000-20,000 words ⚠️ (at limit, monitor closely)

**For reports >20,000 words:**
User must run skill multiple times:
- Run 1: "Generate Part 1 (sections 1-6)" → saves to part1.md
- Run 2: "Generate Part 2 (sections 7-12)" → saves to part2.md
- User manually combines or asks Claude to merge files

**Auto-Continuation Strategy (TRUE Unlimited Length):**

When report exceeds 18,000 words in single run:
1. Generate sections 1-10 (stay under 18K words)
2. Save continuation state file with context preservation
3. Spawn continuation agent via Task tool
4. Continuation agent: Reads state → Generates next batch → Spawns next agent if needed
5. Chain continues recursively until complete

This achieves UNLIMITED length while respecting 32K limit per agent

**Initialize Citation Tracking:**
```
citations_used = []  # Maintain this list in working memory throughout
```

**Section Generation Loop:**

**Pattern:** Generate section content → Use Write/Edit tool with that content → Move to next section
Each Write/Edit call contains ONE section (≤2,000 words per call)

**CRITICAL:** Section order comes from the type-specific MD template loaded in Phase 8. The loop below is the generic pattern — substitute actual sections from the template.

1. **First Section (Executive Summary)** (200-400 words)
   - Generate section content
   - Tool: Write(file, content=frontmatter + Executive Summary)
   - Track citations used
   - Progress: "✓ Executive Summary"

2. **Subsequent Sections** (each 400-2,000 words depending on section guidance in template)
   - Generate section content following template guidance
   - Tool: Edit(file, append section)
   - Track citations used
   - Progress: "✓ [Section Name]"
   - Repeat for ALL sections defined in the type-specific template

... Continue for ALL sections from the template (each section = one Edit tool call, ≤2,000 words)

**CRITICAL:** If you have 10 sections × 1,500 words each = 15,000 words total.
This is OKAY because each Edit call is only 1,500 words (under 2,000 word limit per tool call).
The FILE grows to 15,000 words, but no single tool call exceeds limits.

3. **Bibliography (CRITICAL - ALL Citations)**
   - Generate: COMPLETE bibliography with EVERY citation from citations_used list
   - Format: [1], [2], [3]... [N] - each citation gets full entry
   - Verification: Check citations_used list - if list contains [1] through [73], generate all 73 entries
   - NO ranges ([1-50]), NO placeholders ("Additional citations"), NO truncation
   - Tool: Edit (append to file)
   - Progress: "Generated Bibliography ✓ (N citations)"

4. **Methodology Appendix**
   - Generate: Research process, verification approach (appropriate depth)
   - Tool: Edit (append to file)
   - Progress: "Generated Methodology ✓"

**Phase 8.3: Auto-Continuation Decision Point**

After generating sections, check word count:

**If total output ≤18,000 words:** Complete normally
- Generate Bibliography (all citations)
- Generate Methodology
- Verify complete report
- Save copy to ~/.claude/research_output/
- Done! ✓

**If total output will exceed 18,000 words:** Auto-Continuation Protocol

**Step 1: Save Continuation State**
Create file: `~/.claude/research_output/continuation_state_[report_id].json`

```json
{
  "version": "2.1.1",
  "report_id": "[unique_id]",
  "file_path": "[absolute_path_to_report.md]",
  "mode": "[quick|standard|deep|ultradeep]",

  "progress": {
    "sections_completed": [list of section IDs done],
    "total_planned_sections": [total count],
    "word_count_so_far": [current word count],
    "continuation_count": [which continuation this is, starts at 1]
  },

  "citations": {
    "used": [1, 2, 3, ..., N],
    "next_number": [N+1],
    "bibliography_entries": [
      "[1] Full citation entry",
      "[2] Full citation entry",
      ...
    ]
  },

  "research_context": {
    "research_question": "[original question]",
    "key_themes": ["theme1", "theme2", "theme3"],
    "main_findings_summary": [
      "Finding 1: [100-word summary]",
      "Finding 2: [100-word summary]",
      ...
    ],
    "narrative_arc": "[Current position in story: beginning/middle/conclusion]"
  },

  "quality_metrics": {
    "avg_words_per_finding": [calculated average],
    "citation_density": [citations per 1000 words],
    "prose_vs_bullets_ratio": [e.g., "85% prose"],
    "writing_style": "technical-precise-data-driven"
  },

  "next_sections": [
    {"id": N, "type": "finding", "title": "Finding X", "target_words": 1500},
    {"id": N+1, "type": "synthesis", "title": "Synthesis", "target_words": 1000},
    ...
  ]
}
```

**Step 2: Spawn Continuation Agent**

Use Task tool with general-purpose agent:

```
Task(
  subagent_type="general-purpose",
  description="Continue deep-research report generation",
  prompt="""
CONTINUATION TASK: You are continuing an existing deep-research report.

CRITICAL INSTRUCTIONS:
1. Read continuation state file: ~/.claude/research_output/continuation_state_[report_id].json
2. Read existing report to understand context: [file_path from state]
3. Read LAST 3 completed sections to understand flow and style
4. Load research context: themes, narrative arc, writing style from state
5. Continue citation numbering from state.citations.next_number
6. Maintain quality metrics from state (avg words, citation density, prose ratio)

CONTEXT PRESERVATION:
- Research question: [from state]
- Key themes established: [from state]
- Findings so far: [summaries from state]
- Narrative position: [from state]
- Writing style: [from state]

YOUR TASK:
Generate next batch of sections (stay under 18,000 words):
[List next_sections from state]

Use Write/Edit tools to append to existing file: [file_path]

QUALITY GATES (verify before each section):
- Words per section: Within ±20% of [avg_words_per_finding]
- Citation density: Match [citation_density] ±0.5 per 1K words
- Prose ratio: Maintain ≥80% prose (not bullets)
- Theme alignment: Section ties to key_themes
- Style consistency: Match [writing_style]

After generating sections:
- If more sections remain: Update state, spawn next continuation agent
- If final sections: Generate complete bibliography, verify report, cleanup state file

HANDOFF PROTOCOL (if spawning next agent):
1. Update continuation_state.json with new progress
2. Add new citations to state
3. Add summaries of new findings to state
4. Update quality metrics
5. Spawn next agent with same instructions
"""
)
```

**Step 3: Report Continuation Status**
Tell user:
```
📊 Report Generation: Part 1 Complete (N sections, X words)
🔄 Auto-continuing via spawned agent...
   Next batch: [section list]
   Progress: [X%] complete
```

**Phase 8.4: Continuation Agent Quality Protocol**

When continuation agent starts:

**Context Loading (CRITICAL):**
1. Read continuation_state.json → Load ALL context
2. Read existing report file → Review last 3 sections
3. Extract patterns:
   - Sentence structure complexity
   - Technical terminology used
   - Citation placement patterns
   - Paragraph transition style

**Pre-Generation Checklist:**
- [ ] Loaded research context (themes, question, narrative arc)
- [ ] Reviewed previous sections for flow
- [ ] Loaded citation numbering (start from N+1)
- [ ] Loaded quality targets (words, density, style)
- [ ] Understand where in narrative arc (beginning/middle/end)

**Per-Section Generation:**
1. Generate section content
2. Quality checks:
   - Word count: Within target ±20%
   - Citation density: Matches established rate
   - Prose ratio: ≥80% prose
   - Theme connection: Ties to key_themes
   - Style match: Consistent with quality_metrics.writing_style
3. If ANY check fails: Regenerate section
4. If passes: Write to file, update state

**Handoff Decision:**
- Calculate: Current word count + remaining sections × avg_words_per_section
- If total < 18K: Generate all remaining sections + finish
- If total > 18K: Generate partial batch, update state, spawn next agent

**Final Agent Responsibilities:**
- Generate final content sections
- Generate COMPLETE bibliography using ALL citations from state.citations.bibliography_entries
- Read entire assembled report
- Run validation: python3 ${CLAUDE_PLUGIN_ROOT}/scripts/validate_report.py --report [path]
- Delete continuation_state.json (cleanup)
- Report complete to user with metrics

**Anti-Fatigue Built-In:**
Each agent generates manageable chunks (≤18K words), maintaining quality.
Context preservation ensures coherence across continuation boundaries.

**Generate HTML (Template by Research Type)**

Use the `md_to_html.py` script to convert the markdown report to styled HTML:

```bash
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/md_to_html.py [markdown_file] 
```

The script automatically:
1. Detects research type from `<!-- TYPE: xxx -->` comment in the markdown
2. Selects the matching HTML template (see [research_types.md](./reference/research_types.md#html-templates-visual-presentation) for routing table)
3. Extracts title, date, source count, metrics from the report
4. Converts markdown to styled HTML with template CSS classes (section-title, subsection-title, data-table, citation, executive-summary, etc.)
5. Formats bibliography entries with clickable links
6. Builds a metrics dashboard (sources, sections, word count, mode, confidence)
7. Sets `<html lang="zh-CN">` for Chinese content
8. Removes emoji characters from final output

**Usage options:**
- `--output/-o <path>`: Specify output file path (default: same name with .html extension)

**Template routing** (automatic based on `<!-- TYPE: xxx -->` in markdown):
| Type | Template |
|------|----------|
| `technical` | `technical_report_template.html` |
| `comparison` | `comparison_report_template.html` |
| `stock`, `market` | `mckinsey_report_template.html` |
| `general`, `exploratory` | `general_report_template.html` |

**Requirements:** Python 3 with `markdown` library (`pip install markdown`)

**Generate PDF**
1. Use Task tool with general-purpose agent
2. Invoke generating-pdf skill with markdown as input
3. Save to: `[folder]/research_report_[YYYYMMDD]_[slug].pdf`
4. PDF will auto-open when complete

---

## Output Contract

**Format:** Comprehensive markdown report following type-specific structure from [research types](./reference/research_types.md#template-routing)

**Required sections vary by research type** — see [research_types.md](./reference/research_types.md#template-routing) for full per-type section lists. All types require Bibliography and Methodology appendix.

**Bibliography Requirements (ZERO TOLERANCE - Report is UNUSABLE without complete bibliography):**
- ✅ MUST include EVERY citation [N] used in report body (if report has [1]-[50], write all 50 entries)
- ✅ Format: [N] Author/Org (Year). "Title". Publication. URL (Retrieved: Date)
- ✅ Each entry on its own line, complete with all metadata
- ❌ NO placeholders: NEVER use "[8-75] Additional citations", "...continue...", "etc.", "[Continue with sources...]"
- ❌ NO ranges: Write [3], [4], [5]... individually, NOT "[3-50]"
- ❌ NO truncation: If 30 sources cited, write all 30 entries in full
- ⚠️ Validation WILL FAIL if bibliography contains placeholders or missing citations
- ⚠️ Report is GARBAGE without complete bibliography - no way to verify claims

**Strictly Prohibited:**
- Placeholder text (TBD, TODO, [citation needed])
- Uncited major claims
- Broken links
- Missing required sections
- **Short summaries instead of detailed analysis**
- **Vague statements without specific evidence**

**Writing Standards:** See [Content Requirements](#content-requirements) above — narrative-driven prose, precision, economy, citation density, anti-fatigue checks.

**Quality gates:** See [Quality Standards](#quality-standards-always-enforce) below.

---

## Error Handling & Stop Rules

**Stop immediately if:**
- 2 validation failures on same error → Pause, report, ask user
- <5 sources after exhaustive search → Report limitation, request direction
- User interrupts/changes scope → Confirm new direction

**Graceful degradation:**
- 5-10 sources → Note in limitations, proceed with extra verification
- Time constraint reached → Package partial results, document gaps
- High-priority critique issue → Address immediately

**Error format:**
```
⚠️ Issue: [Description]
📊 Context: [What was attempted]
🔍 Tried: [Resolution attempts]
💡 Options:
   1. [Option 1]
   2. [Option 2]
   3. [Option 3]
```

---

## Quality Standards (Always Enforce)

Every report must:
- Minimum 2,000 words (standard mode), scales with mode
- 10+ sources (document if fewer)
- 3+ sources per major claim
- Average credibility score >60/100
- Executive summary <250 words
- Full citations with URLs
- Credibility assessment
- All type-required sections present and detailed
- Methodology documented
- No placeholders (TBD, TODO, [citation needed])

**Priority:** Thoroughness over speed. Quality > speed.

---

## Inputs & Assumptions

**Required:**
- Research question (string)

**Optional:**
- Mode (quick/standard/deep/ultradeep)
- Time constraints
- Required perspectives/sources
- Output format

**Assumptions:**
- User requires verified, citation-backed information
- 10-50 sources available on topic
- Time investment: 5-45 minutes

---

## When to Use / NOT Use

**Use when:**
- Comprehensive analysis (10+ sources needed)
- Comparing technologies/approaches/strategies
- State-of-the-art reviews
- Multi-perspective investigation
- Technical decisions
- Market/trend analysis

**Do NOT use:**
- Simple lookups (use WebSearch)
- Debugging (use standard tools)
- 1-2 search answers
- Time-sensitive quick answers

---

## Progressive References (Load On-Demand)

**Do not inline these - reference only:**
- [Research Types](./reference/research_types.md) — Type detection, search angles, template routing (MD + HTML)

**Context Management:** Load files on-demand for current phase only. Do not preload all content.
- Phase 1: Load research_types.md for type detection and search angle filtering
- Phase 8: Load type-specific MD template per routing table; load HTML template for browser output

---

<!-- STATIC CONTEXT BLOCK END -->
<!-- ⚡ Above content is cacheable (>1024 tokens, static) -->
<!-- 📝 Below: Dynamic content (user queries, retrieved data, generated reports) -->
<!-- This structure enables 85% latency reduction via prompt caching -->

---

## Dynamic Execution Zone

**User Query Processing:**
[User research question will be inserted here during execution]

**Retrieved Information:**
[Search results and sources will be accumulated here]

**Generated Analysis:**
[Findings, synthesis, and report content generated here]

**Note:** This section remains empty in the skill definition. Content populated during runtime only.
