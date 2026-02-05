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

**Smart Request Examples**:
- `使用 gradient-glass 风格生成15页PPT` → Only asks for document
- `生成一个10页的产品发布会PPT` → Asks: document + style
- `生成一个极简风格的PPT` → Matches to linear-web, asks: document + confirmation
- `生成一个赛博朋克霓虹风格的PPT` → Generates custom style, asks: document + confirmation
- `帮我生成PPT` → Asks: document + style + slide count

## What This Command Does

1. **Discovers Available Styles**: Dynamically loads all styles from styles/ directory
2. **Parses Your Request**: Intelligently extracts what you've already specified
3. **Asks Only What's Missing**: Smart questioning - skips what you provided
4. **Matches or Generates Style**: Finds best match or creates custom style on-the-fly
5. **Plans Content**: Analyzes document structure and allocates slides per chapter
6. **Generates Images**: Uses MCP to create high-quality 16:9 slide images
7. **Creates Viewer**: Generates an HTML5 viewer with keyboard navigation

## Smart Questioning Flow

The system only asks for information not already in your request:

**Step 1: Document**
- If provided: uses it
- If missing: asks "请提供要转换为PPT的文档路径或直接输入内容"

**Step 2: Style Selection**
- **Exact ID** (e.g., "gradient-glass"): Uses directly, no questions
- **Description** (e.g., "极简风格"): Matches to existing style, confirms
- **No match** (e.g., "赛博朋克"): Generates custom style, asks to accept/regenerate
- **Not specified**: Shows all available styles dynamically

**Step 3: Slide Count**
- If specified: uses it
- If missing: asks (5/10/15/20+/custom)

**Step 4: Resolution**
- If specified: uses it
- If missing: asks (2K recommended / 4K high quality)
- Default: 2K

**Step 5: Page Allocation**
- Shows automatic allocation based on document structure
- Asks: "Accept automatic or customize per chapter?"
- If customize: asks for each chapter's page count

## Dynamic Style System

Styles are automatically discovered from `${CLAUDE_PLUGIN_ROOT}/styles/`:

**Built-in Styles**:
- **gradient-glass**: Modern 3D glass, neon gradients, tech/business
- **linear-web**: Minimalist flat, Swiss design, startups/portfolios
- **vector-illustration**: Warm retro, education/creative

**Style Matching**:
- Exact ID match → Direct use
- Keyword match → Auto-match to tags/use_cases
- No match → Generate custom style in memory (no file creation)
- Full AI control over style interpretation

**To see all available styles**:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/list-styles.sh
```

## Page Allocation Control

**Automatic Allocation** (default):
- System analyzes document chapters
- Proportionally allocates pages based on content length
- Reserves: Cover (1) + Summary (1-2 for 10+ slides)

**Custom Allocation**:
- Manually specify pages per chapter
- Perfect for emphasizing specific sections
- System validates total matches requested count

Example allocation for 15 slides:
```
Cover: 1
Chapter 1 "Introduction": 2 pages (13%)
Chapter 2 "Core Concepts": 5 pages (33%)
Chapter 3 "Implementation": 5 pages (33%) ← Emphasized
Chapter 4 "Case Studies": 1 page (7%)
Summary: 1 page
Total: 15 ✓
```

## Requirements

Before using this command, ensure:

1. **MCP Server** is configured:
   - Check `.mcp.json` in plugin directory
   - Run: `/nanobanana-ppt:setup` to verify

2. **API Key** is set:
   ```bash
   export GEMINI_API_KEY='your-api-key'
   ```
   - Get your key from: https://makersuite.google.com/app/apikey

3. **uvx** is installed (for MCP server):
   ```bash
   pip install uv
   ```

## Examples

### Example 1: Complete Request
```
User: 使用 gradient-glass 风格，为我的会议纪要生成5页PPT，2K分辨率
System: (asks only for document path)
User: meeting-notes.md
System: Generates 5 slides with gradient-glass style
```
**Questions asked**: 1

### Example 2: Smart Style Matching
```
User: 生成一个极简风格的10页PPT
System: 请提供文档路径
User: product-launch.md
System: 检测到您想要极简风格，建议使用 linear-web 风格，确认吗？
User: 是
System: Generates 10 slides with linear-web style
```
**Questions asked**: 2

### Example 3: Custom Style Generation
```
User: 生成一个赛博朋克霓虹风格的15页PPT
System: 请提供文档路径
User: tech-trends.md
System: (generates custom style, displays configuration)
  风格名称: 赛博朋克霓虹风格
  风格标签: cyberpunk, neon, futuristic, dark, glowing
  基础提示词模板: ...
System: 这个风格配置是否符合您的预期？
User: 接受
System: Generates 15 slides with custom cyberpunk style
```
**Questions asked**: 2

### Example 4: Custom Allocation
```
User: 使用 vector-illustration 风格，为产品路线图生成15页PPT，重点在实施章节
System: 请提供文档路径
User: roadmap.md
System: (shows automatic allocation: Implementation=4 pages)
System: 请选择页数分配方式
User: 自定义每章页数
System: (asks for each chapter)
User: Sets Implementation to 7 pages, adjusts others
System: Validates total = 15, generates with custom allocation
```
**Questions asked**: 1 (document) + 5 (chapter allocations)

## Output

After generation, you'll receive:

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
├── images/ (slide-01.png, slide-02.png, ...)
├── slides_plan.json
├── prompts.json
└── index.html (HTML5 viewer)

🎬 查看演示文稿:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
open outputs/20260122_103000/index.html
```

### Viewer Controls

- `←` `→` : Navigate slides
- `↑` `Home` : Jump to first slide
- `↓` `End` : Jump to last slide
- `Space` : Pause/resume autoplay
- `ESC` : Toggle fullscreen
- `H` : Hide/show controls

## Tips

✅ **For Better Results**:
- Use well-structured markdown with clear headings (`#`, `##`)
- Keep chapter content balanced in length
- Use bullet points for key takeaways
- Specify style ID if you know exactly what you want

✅ **Style Selection**:
- **Tech/Business**: Use gradient-glass (modern, 3D, professional)
- **Startups/Portfolios**: Use linear-web (minimal, clean, Swiss)
- **Education/Stories**: Use vector-illustration (warm, friendly)
- **Custom**: Describe your style, AI will generate it

✅ **Slide Count Guidelines**:
- 5 slides: ~5 minutes (quick updates)
- 10 slides: ~15 minutes (standard presentations)
- 15 slides: ~30 minutes (detailed topics)
- 20+ slides: ~45-60 minutes (comprehensive coverage)

✅ **Resolution**:
- 2K: Daily presentations, screen sharing, online distribution
- 4K: Printing, large displays, portfolio pieces

## Troubleshooting

**"MCP server not found"**
```bash
# Check configuration
cat .claude-plugin/.mcp.json

# Run setup
/nanobanana-ppt:setup
```

**"API key not set"**
```bash
export GEMINI_API_KEY='your-api-key'
# Add to ~/.zshrc for persistence
```

**"Generation takes too long"**
This is normal:
- 2K: ~30 seconds per slide
- 4K: ~60 seconds per slide
- 10-slide deck: 5-10 minutes total

**Style not found**
- Check exact style ID using: `${CLAUDE_PLUGIN_ROOT}/scripts/list-styles.sh`
- Or describe the style, system will match or generate it

**Want different allocation?**
- Choose "自定义每章页数" when prompted
- Adjust page counts per chapter as needed

---

Now analyze the document in $ARGUMENTS and help create a professional presentation.

**Workflow**:
1. Parse user's request for: document, style, slides, resolution
2. Discover available styles via list-styles.sh
3. Match/generate style based on request
4. Ask only for missing information
5. Analyze document and plan content allocation
6. Generate slides via MCP
7. Present results with viewer path

If no document provided, ask user for document path or content.
