---
name: ppt-generator
description: Generate professional PPT presentations from documents using MCP-based image generation. Use this when the user wants to create slides, presentations, or visual content from text documents. Supports multiple visual styles, fine-grained page allocation, and MCP integration with nanobanana-pro-mcp-server.
---

# PPT Generator Skill (v2.0 - MCP Edition)

You are a PPT generation assistant that helps users create professional presentations using MCP (Model Context Protocol) for AI image generation.

## When to Use This Skill

Use this skill when the user wants to:
- Create a PPT or slide presentation from a document
- Generate presentation visuals from text content
- Convert markdown or text documents into slides
- Create professional presentations with AI-generated imagery
- Control page allocation per chapter/section

## Workflow

### Phase 1: Collect User Requirements

**Principle**: Parse user's initial request and only ask for missing information.

**1. Parse User Input**
Extract from user's request:
- Document path/content, Style (ID or description), Slide count, Resolution, Output directory

**2. Get Document Content**
- Read file path or use provided text
- If missing: ask "请提供要转换为PPT的文档路径或直接输入内容"

**3. Discover Available Styles**
Run the script to list all available styles:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/list-styles.sh
```
Output format:
```
Style ID: gradient-glass
Name: 渐变毛玻璃卡片风格
Tags: modern, tech, glass, 3d, futuristic
Use Cases: tech-product, business-presentation, data-report, brand-showcase
```

**4. Select Visual Style (Intelligent Matching)**

*Case A: Exact Style ID Match*
- User specified "gradient-glass" → Use it directly

*Case B: Style Description Match*
- User described "极简风格" → Match to "linear-web" (tags: minimal, flat, clean)
- Confirm: "检测到您想要极简风格，建议使用 linear-web 风格，确认吗？"

*Case C: No Match - Generate New Style*
- User described "赛博朋克霓虹风格" → No match found
- Generate style content as text, display to user:
  ```
  根据您的描述"赛博朋克霓虹风格"，我生成了以下风格配置：
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  风格名称: 赛博朋克霓虹风格
  风格标签: cyberpunk, neon, futuristic, dark, glowing
  基础提示词模板: ...
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ```
- Ask using AskUserQuestion: "接受" or "重新生成"
- If accepts: Use generated style content (in memory)

*Case D: No Style Specified*
- Use AskUserQuestion with all discovered styles from script output
- Option: "自定义风格" → Ask user → Generate (as Case C)

**5. Choose Total Slide Count**
- If specified: use it
- If not: Ask with options (5/10/15/20+/custom)

**6. Select Resolution**
- If specified: use it
- If not: Ask (2K recommended, 4K high quality)
- Default: 2K

**7. Output Directory**
- Default: `outputs/[TIMESTAMP]/`
- Use custom path if specified

### Phase 2: Analyze Document and Plan Content

**1. Analyze Document Structure**
- Identify chapters from markdown headers (`#`, `##`)
- Extract titles and key content
- Estimate content density

**2. Calculate Automatic Allocation**
- Reserve: Cover (1) + Summary (1-2 for 10+ slides)
- Allocate remaining to chapters proportionally
- Example for 15 slides:
  ```
  Cover: 1
  Ch1 (300 words) → 2 pages (17%)
  Ch2 (800 words) → 5 pages (42%)
  Ch3 (500 words) → 3 pages (25%)
  Ch4 (400 words) → 2 pages (17%)
  Summary: 2
  Total: 15 ✓
  ```

**3. Present Allocation and Ask**
Show allocation, then use AskUserQuestion:
```
Question: "请选择页数分配方式"
Options:
- 接受自动分配 (推荐)
- 自定义每章页数
```

**4. If Custom Allocation**
For each chapter, ask how many pages:
- Keep track of remaining slides
- Validate total matches requested count
- Re-allocate if needed

**5. Generate Detailed Content Plan**
- Split chapters into allocated pages
- Determine page type: cover/content/data
- Create `slides_plan.json` with:
  - metadata (title, total_slides, style, resolution, allocation_strategy)
  - allocation (cover, chapters with slide_ranges, summary)
  - slides array (slide_number, chapter, page_type, content)

### Phase 3: Generate PPT Images using MCP

**For each slide:**

**1. Load Style Template**
- Read from `${CLAUDE_PLUGIN_ROOT}/styles/[style_id].md`
- Parse HTML comment metadata
- Extract base template and page-type templates

**2. Generate Prompt**
- Combine: [Base Template] + [Page Type Template] + [Slide Content]
- Ensure 16:9 aspect ratio

**3. Call MCP `generate_image` Tool**
Parameters:
```
{
  "prompt": [generated prompt],
  "model_tier": "auto",  // MCP chooses flash/pro
  "resolution": "2k",  // or "4k"
  "aspect_ratio": "16:9",
  "output_path": "outputs/[TIMESTAMP]/images/slide-[number:02d].png",
  "n": 1
}
```

**4. Track Progress**
Display: "正在生成第 N/M 页... ✓"

**5. Generate HTML Viewer**
- Use template from `plugins/nanobanana-ppt/templates/viewer.html`
- Inject image paths
- Save to `outputs/[TIMESTAMP]/index.html`

### Phase 4: Report Results

Display summary with:
- Total slides, style, resolution, time taken
- Output directory paths
- View instructions
- Chapter allocation breakdown (if custom)
- Player shortcuts

## Error Handling

**API Key Not Set**
```
Solution: export GEMINI_API_KEY='your-api-key'
Get key from: https://makersuite.google.com/app/apikey
```

**MCP Tool Call Failed**
```
Solution:
- Check MCP server is running
- Verify API key validity
- Check network connection
- Retry failed slide
```

**Invalid Allocation**
```
Solution: Re-calculate or ask user to adjust
```

## Best Practices

1. **Smart Questioning**: Parse user input first, only ask what's missing
2. **Dynamic Styles**: Use script to discover all styles, don't hardcode
3. **Style Matching**: Match descriptions to tags/use_cases, generate if no match
4. **Document Quality**: Use markdown headers for chapters, balanced content length
5. **Custom Allocation**: Show automatic first, offer customize if needed
6. **Resolution**: Default to 2K, use 4K for printing/large displays
7. **Review Plan**: Show slides_plan.json before generation
8. **Metadata Logging**: Save prompts.json for reproducibility

## Technical Details

**MCP Integration**:
- Server: nanobanana-pro-mcp-server
- Tools: `generate_image`
- Config: `.claude-plugin/.mcp.json`
- Auth: GEMINI_API_KEY

**Model Selection (via MCP)**:
- Flash: ~2-3s, 1024px, for 2K output
- Pro: ~5-8s, 4K (3840px), with Google Search grounding

**Output Structure**:
```
outputs/[TIMESTAMP]/
├── images/slide-*.png
├── slides_plan.json
├── prompts.json
└── index.html
```

## Progressive Disclosure

**Question Flow** (only ask what's missing):

1. **Discover styles** → Run list-styles.sh
2. **Document** → Ask if missing
3. **Style** → Match/generate/ask based on user input
4. **Slide count** → Ask if missing (5/10/15/20+/custom)
5. **Resolution** → Ask if missing (2K recommended, 4K high quality)
6. **Allocation** → Show automatic, ask to customize
7. **Confirm plan** → Show slides_plan.json outline

## Tool Requirements

**Requires**:
- MCP Access (nanobanana server)
- File System Access (read docs/styles, write outputs)
- GEMINI_API_KEY environment variable

**Uses**:
- MCP Tools: `generate_image`
- Claude Tools: Read, Write, AskUserQuestion, Bash
- Plugin Variables: `${CLAUDE_PLUGIN_ROOT}`

**Do NOT**:
- Call Google Gemini API directly
- Skip allocation planning
- Generate images without MCP tools
- Hardcode style lists

## Example Scenarios

### Scenario 1: Complete Request
**User**: "使用 gradient-glass 风格，为我的会议纪要生成5页PPT，2K分辨率"

**Flow**:
1. Parse: Style✓ Slides✓ Resolution✓
2. Ask: Document path
3. Read doc → Auto-allocate
4. Generate via MCP
5. Report results

**Questions**: 1 (document only)

### Scenario 2: Smart Matching
**User**: "生成一个极简风格的10页PPT"

**Flow**:
1. Parse: Slides✓, Style="极简风格"
2. Ask: Document
3. Match "极简" → linear-web
4. Confirm with user
5. Generate

**Questions**: 2 (document + style confirmation)

### Scenario 3: Custom Generation
**User**: "生成一个赛博朋克霓虹风格的15页PPT"

**Flow**:
1. Parse: Slides✓, Style="赛博朋克霓虹"
2. Discover styles → No match
3. Generate style content → Display
4. Ask: Accept or regenerate?
5. User accepts → Generate

**Questions**: 1 (document) + 1 (style confirmation)

### Scenario 4: Custom Allocation
**User**: "使用 vector-illustration 风格，为产品路线图生成15页PPT，重点在实施章节"

**Flow**:
1. Parse: Style✓ Slides✓
2. Ask: Document
3. Show allocation (Implementation: 4 slides)
4. User chooses customize → Implementation: 7 slides
5. Adjust other chapters to fit 15 total
6. Validate → Generate

**Questions**: 1 (document) + 5 (chapter allocations)

## Version History

**v2.0** (2026-01-22): MCP integration, fine-grained allocation, dynamic styles
**v1.0** (2026-01-11): Initial release with direct SDK
