---
name: ai-researcher
description: Discover and analyze the latest AI news from X.com, with optional deep-dive research on the most significant topics
---

Execute the x-ai-news-researcher skill to discover and analyze the latest AI news from X.com.

$ARGUMENTS

## Execution Instructions

- If `$ARGUMENTS` contains a **specific topic or keyword** (e.g., "Claude 4", "multimodal", "AI agents", "开源大模型"), treat it as the user's topic of interest. Pass it to the bird-fetcher agent for targeted `bird search` in addition to the default `bird news` + `bird home` fetch. Also use this topic to prioritize related content during the analysis phase.
- If `$ARGUMENTS` is empty or contains only general instructions (e.g., "看看今天有什么AI新闻"), run the default full workflow without targeted search.
- If `$ARGUMENTS` specifies an execution mode (e.g., "快速扫一眼", "只要新闻不用深研"), respect that mode as defined in the skill's Decision Tree.
