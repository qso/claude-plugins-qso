# Research Types

## Overview

Research type determines which search angles to prioritize and which report structure to use. It operates independently from research mode (quick/standard/deep/ultradeep), which controls depth.

- **Mode** = how deep (vertical axis: quick → ultradeep)
- **Type** = what kind (horizontal axis: technical, comparison, market, etc.)

---

## Auto-Detection Rules

Detect research type from the query by matching patterns top-to-bottom. **First match wins.** If no pattern matches, default to `general`.

### Type: `technical`

**Trigger patterns:**
- Query mentions a specific technology, framework, library, language, protocol, algorithm, or tool by name (e.g., "React Server Components", "gRPC", "WebAssembly", "Kubernetes", "SQLite", "RAFT consensus")
- Query contains: "how does X work", "architecture of", "internals", "implementation", "technical deep-dive", "under the hood", "原理", "技术调研"
- Query contains: "best practices for", "design patterns", "performance of"
- Query focuses on a specific technical artifact rather than a broad field

### Type: `comparison`

**Trigger patterns:**
- Query contains: "vs", "versus", "compare", "comparison", "对比", "A or B", "which is better", "difference between", "alternative to", "migrate from X to Y", "选型"
- Query structure implies side-by-side evaluation of 2+ options

### Type: `market`

**Trigger patterns:**
- Query contains: "market size", "market share", "TAM", "SAM", "competitive landscape", "competitors", "industry analysis", "business model", "go-to-market", "pricing strategy", "investment", "funding", "valuation", "市场", "竞品"
- Query contains "trend", "forecast", "outlook", "growth" combined with business/market context
- Query focuses on commercial dynamics rather than technical mechanics

### Type: `stock`

**Trigger patterns:**
- Query mentions a specific stock ticker or public company in investment context (e.g., "AAPL", "Tesla stock", "NVDA analysis")
- Query contains: "stock analysis", "股票分析", "个股分析", "buy or sell", "投资分析", "估值", "valuation", "PE ratio", "earnings", "财报", "K线", "技术面", "基本面"
- Query asks about investment thesis, price target, or whether to buy/hold/sell a specific stock
- Query focuses on a single company's investment merit rather than a broad market

### Type: `exploratory`

**Trigger patterns:**
- Query is broad or open-ended: "what is the state of", "overview of", "landscape of", "survey of", "what should I know about", "了解一下"
- Query mentions a broad field without narrowing to a specific artifact (e.g., "AI safety" rather than "RLHF algorithm")

### Type: `general` (default)

**Fallback:** Used when no specific pattern matches. Uses the full set of 8 search angles and the standard report template.

---

## User Override

The user can explicitly set research type by stating it:
- "technical research on Next.js App Router"
- "comparison: PostgreSQL vs CockroachDB"
- "market analysis of AI coding assistants"
- "stock analysis of NVDA"
- "分析一下特斯拉的股票"
- "技术调研 Bun runtime"

If the user explicitly states a type, use it regardless of auto-detection.

**Announce** the detected/selected type in the plan step:
```
"Starting standard mode research, type: technical (15-30 sources)"
```

---

## Search Angles Per Type

Each type defines **preferred** and **optional** search angles. Preferred angles are always executed. Optional angles are included only if the mode has capacity (deep/ultradeep) or if initial results suggest relevance.

The angle names reference the 8 canonical search angles defined in SKILL.md Phase 3 RETRIEVE.

### `technical`

**Preferred (always execute):**
1. Core topic (semantic) — what is it, origin, what problem it solves
2. Technical details (keyword) — APIs, architecture, internals, design philosophy
3. Recent developments (date-filtered) — latest version, changelog, roadmap
4. Critical analysis/limitations — known issues, gotchas, performance caveats, trade-offs

**Optional (deep/ultradeep or if relevant):**
5. Alternative perspectives (comparison) — brief positioning vs alternatives
6. Academic sources — if relevant papers or formal analysis exist

**Skip unless specifically relevant:**
- Statistical/data sources (include only if benchmarks are central to the query)
- Industry analysis (not relevant for pure technical research)

### `comparison`

**Preferred (always execute):**
1. Core topic (semantic) — understand each option independently
2. Alternative perspectives (comparison) — direct A vs B comparisons, migration guides
3. Technical details (keyword) — feature-level differences, API differences
4. Critical analysis/limitations — weaknesses and failure modes of each option
5. Statistical/data sources — benchmarks, adoption metrics, performance data

**Optional:**
6. Recent developments — latest updates for each option
7. Academic sources — if formal evaluations exist

**Skip unless specifically relevant:**
- Industry analysis (unless the comparison is business-oriented)

### `market`

**Preferred (always execute):**
1. Core topic (semantic) — market definition and boundaries
2. Industry analysis — market size, trends, key players, positioning
3. Statistical/data sources — revenue figures, growth rates, TAM/SAM/SOM
4. Recent developments (date-filtered) — latest deals, launches, pivots, funding rounds
5. Alternative perspectives — contrarian views, market risks, disruption threats

**Optional:**
6. Academic sources — if relevant research reports exist
7. Critical analysis — market risks, regulatory risks, failure modes

**Skip unless specifically relevant:**
- Technical details (unless the market is defined by a specific technology)

### `stock`

**Preferred (always execute):**
1. Core topic (semantic) — company overview, business model, revenue structure, what the company does
2. Statistical/data sources — financial metrics (PE, PB, ROE, revenue growth, margins, EPS), historical stock price data
3. Recent developments (date-filtered) — latest earnings reports, management changes, product launches, guidance updates
4. Critical analysis/limitations — bear case, risk factors, regulatory headwinds, competitive threats
5. Industry analysis — sector positioning, industry tailwinds/headwinds, peer comparison

**Optional (deep/ultradeep or if relevant):**
6. Alternative perspectives — bull vs bear debate, short seller reports, contrarian views
7. Academic sources — if relevant financial research exists

**Skip unless specifically relevant:**
- Technical details (unless the company is a tech company and technical moat matters)

### `exploratory`

**Preferred:** All 8 angles, but with reduced depth per angle. This type benefits from breadth over depth.

### `general`

**All 8 angles** at standard depth. No filtering applied — this is the current default behavior.

---

## Template Routing

Each research type maps to a **MD template** (section structure + writing guidance, used in Phase 8 report generation) and an **HTML template** (visual presentation, used for browser output).

### MD Templates (Report Structure)

Load the appropriate MD template at the start of Phase 8 (PACKAGE) for section order, per-section writing guidance, and generation workflow.

| Type | MD Template |
|------|------------|
| `technical` | [technical_report_template.md](../templates/technical_report_template.md) |
| `comparison` | [comparison_report_template.md](../templates/comparison_report_template.md) |
| `market` | [market_report_template.md](../templates/market_report_template.md) |
| `stock` | [stock_report_template.md](../templates/stock_report_template.md) |
| `exploratory` | [report_template.md](../templates/report_template.md) (generic Finding structure) |
| `general` | [report_template.md](../templates/report_template.md) (default, unchanged) |

### HTML Templates (Visual Presentation)

Select the HTML template when generating browser-viewable output. Each template has a distinct aesthetic matched to its content type.

| Type | HTML Template | Aesthetic |
|------|--------------|-----------|
| `technical` | [technical_report_template.html](../templates/technical_report_template.html) | Minimalist sci-fi/tech |
| `comparison` | [comparison_report_template.html](../templates/comparison_report_template.html) | Side-by-side editorial |
| `stock`, `market` | [mckinsey_report_template.html](../templates/mckinsey_report_template.html) | McKinsey data-dense |
| `general`, `exploratory` | [general_report_template.html](../templates/general_report_template.html) | Clean modern journal |

### Special Rules

- **`stock` type:** Report must include a prominent disclaimer: "This analysis is for research and educational purposes only and does not constitute investment advice."
- **All types:** Bibliography and Methodology Appendix sections are always required regardless of type.
