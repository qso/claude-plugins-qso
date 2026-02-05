---
name: generate
description: Generate a professional PPT presentation from a document using AI
---

# Generate PPT Command

Generate a professional PowerPoint-style presentation from a document using MCP-based AI image generation.

## Usage

```
/nanobanana-ppt:generate [document-path]
```

**Smart Examples**:
- `使用 gradient-glass 风格生成15页PPT，2K分辨率` → Only asks for document
- `生成一个10页的产品发布会PPT` → Asks: document + style
- `生成一个极简风格的PPT` → Matches to linear-web, confirms
- `生成一个赛博朋克霓虹风格的PPT` → Generates custom style, confirms
- `帮我生成PPT` → Asks: document + style + slides

## Workflow (4 Phases)

### Phase 1: Collect User Requirements

**Principle**: Parse user's request and only ask for missing information.

1. **Parse User Input**
   Extract: Document, Style, Slide count, Resolution, Output directory

2. **Get Document Content**
   - If provided: use it
   - If missing: ask "请提供要转换为PPT的文档路径或直接输入内容"

3. **Discover Available Styles**
   Run: `${CLAUDE_PLUGIN_ROOT}/scripts/list-styles.sh`

   Output shows:
   ```
   Style ID: gradient-glass
   Name: 渐变毛玻璃卡片风格
   Tags: modern, tech, glass, 3d, futuristic
   Use Cases: tech-product, business-presentation
   ```

4. **Select Visual Style (Intelligent Matching)**
   - **Exact ID** (e.g., "gradient-glass"): Use directly
   - **Description** (e.g., "极简风格"): Match to linear-web, confirm
   - **No match** (e.g., "赛博朋克"): Generate custom style, ask to accept/regenerate
   - **Not specified**: Show all available styles, ask to choose

5. **Choose Total Slide Count**
   - If specified: use it
   - If missing: Ask (5/10/15/20+/custom)

6. **Select Resolution**
   - If specified: use it
   - If missing: Ask (2K recommended / 4K high quality)
   - Default: 2K

### Phase 2: Analyze Document and Plan Content

1. **Analyze Document Structure**
   - Identify chapters from markdown headers
   - Extract titles and key content
   - Estimate content density

2. **Calculate Automatic Allocation**
   - Reserve: Cover (1) + Summary (1-2 for 10+ slides)
   - Allocate remaining to chapters proportionally
   - Example: 15 slides = Cover(1) + Ch1(2) + Ch2(5) + Ch3(3) + Ch4(2) + Summary(2)

3. **Present Allocation and Ask**
   Show allocation, ask: "接受自动分配 or 自定义每章页数?"

4. **If Custom Allocation**
   Ask for each chapter, validate total matches requested count

5. **Generate slides_plan.json**
   With metadata, allocation details, and slide content

### Phase 3: Generate PPT Images using MCP

For each slide:

1. **Load Style Template**
   Read from `${CLAUDE_PLUGIN_ROOT}/styles/[style_id].md`

2. **Generate Prompt**
   Combine: [Base Template] + [Page Type Template] + [Slide Content]

3. **Call MCP `generate_image` Tool**
   - model_tier: "auto"
   - resolution: "2k" or "4k"
   - aspect_ratio: "16:9"
   - output: `outputs/[TIMESTAMP]/images/slide-[number].png`

4. **Track Progress**
   Display: "正在生成第 N/M 页... ✓"

5. **Generate HTML Viewer**
   Use template, inject image paths
   Save to `outputs/[TIMESTAMP]/index.html`

### Phase 4: Report Results

Display summary:
- Total slides, style, resolution, time
- Output directory paths
- View instructions
- Chapter allocation (if custom)
- Player shortcuts

## Dynamic Style System

Styles are automatically discovered from `${CLAUDE_PLUGIN_ROOT}/styles/`:

**Built-in Styles**:
- **gradient-glass**: Modern 3D glass, neon gradients, tech/business
- **linear-web**: Minimalist flat, Swiss design, startups/portfolios
- **vector-illustration**: Warm retro, education/creative

**Style Matching**:
- Exact ID → Direct use
- Keywords → Auto-match to tags/use_cases
- No match → Generate in memory (no file)
- Full AI control over style interpretation

**See all styles**:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/list-styles.sh
```

## Page Allocation Control

**Automatic** (default): Proportional to chapter length

**Custom**: Manually specify per chapter, emphasize important sections

Example (15 slides):
```
Cover: 1
Ch1 "Introduction": 2 pages
Ch2 "Core Concepts": 5 pages
Ch3 "Implementation": 5 pages ← Emphasized
Ch4 "Case Studies": 1 page
Summary: 1 page
Total: 15 ✓
```

## Requirements

1. **MCP Server**: Configured in `.mcp.json`
2. **API Key**: `export GEMINI_API_KEY='your-api-key'`
   - Get from: https://makersuite.google.com/app/apikey
3. **uvx**: `pip install uv` (for MCP server)

## Examples

### Example 1: Complete Request
```
User: 使用 gradient-glass 风格，为我的会议纪要生成5页PPT，2K分辨率
System: 请提供文档路径
User: meeting-notes.md
System: Generates 5 slides
```
**Questions**: 1

### Example 2: Smart Matching
```
User: 生成一个极简风格的10页PPT
System: 请提供文档路径
User: product-launch.md
System: 检测到您想要极简风格，建议使用 linear-web 风格，确认吗？
User: 是
System: Generates 10 slides
```
**Questions**: 2

### Example 3: Custom Style
```
User: 生成一个赛博朋克霓虹风格的15页PPT
System: 请提供文档路径
User: tech-trends.md
System: (generates and displays custom style)
System: 这个风格配置是否符合您的预期？
User: 接受
System: Generates 15 slides
```
**Questions**: 2

### Example 4: Custom Allocation
```
User: 使用 vector-illustration 风格，为产品路线图生成15页PPT，重点在实施章节
System: 请提供文档路径
User: roadmap.md
System: (shows allocation, asks custom/auto)
User: 自定义
System: (asks for each chapter)
User: Sets Implementation to 7 pages
System: Validates, generates
```
**Questions**: 1 (document) + 5 (chapters)

## Output

```
✅ PPT 生成成功！

📊 生成统计:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
总页数: 15 页
风格: 渐变毛玻璃卡片风格
分辨率: 2K (2752x1536)

📁 输出位置:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
outputs/20260122_103000/
├── images/slide-*.png
├── slides_plan.json
├── prompts.json
└── index.html

🎬 查看:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
open outputs/20260122_103000/index.html
```

**Viewer Controls**:
- `←` `→` : Navigate
- `↑` `Home` : First slide
- `↓` `End` : Last slide
- `Space` : Pause/Resume autoplay
- `ESC` : Fullscreen
- `H` : Hide/Show controls

## Tips

✅ **Better Results**:
- Well-structured markdown with clear headings
- Balanced chapter lengths
- Bullet points for key takeaways
- Specify style ID if you know it

✅ **Style Selection**:
- **Tech/Business**: gradient-glass
- **Startups/Portfolios**: linear-web
- **Education/Stories**: vector-illustration
- **Custom**: Describe your style, AI generates it

✅ **Slide Count**:
- 5 slides: ~5 minutes
- 10 slides: ~15 minutes
- 15 slides: ~30 minutes
- 20+ slides: ~45-60 minutes

✅ **Resolution**:
- 2K: Daily presentations, screen sharing
- 4K: Printing, large displays

## Error Handling

**API Key Not Set**
```bash
export GEMINI_API_KEY='your-api-key'
```

**MCP Tool Call Failed**
- Check MCP server running
- Verify API key
- Check network
- Retry failed slide

**Invalid Allocation**
- Re-calculate
- Ask user to adjust

---

Now analyze the document in $ARGUMENTS and help create a professional presentation.

**Workflow**:
1. Parse request for: document, style, slides, resolution
2. Discover styles via list-styles.sh
3. Match/generate style
4. Ask only for missing info
5. Analyze document, plan allocation
6. Generate via MCP
7. Present results

If no document provided, ask user for document path or content.
