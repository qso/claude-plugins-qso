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

1. **Get Document Content**
   - If user provides a file path, read the file content
   - If user provides text directly, use that content
   - If not provided, ask the user for document path or content

2. **Select Visual Style**
   - Read available styles from `plugins/nanobanana-ppt/styles/` directory
   - Parse style metadata from HTML comments at the top of each `.md` file
   - Available built-in styles:
     - `gradient-glass`: High-end gradient glass card style with 3D objects, perfect for tech products and business presentations
     - `vector-illustration`: Warm flat vector illustration style with black outlines, perfect for education and creative proposals
   - Present styles to user with their descriptions and use cases
   - Ask user to choose a style

3. **Choose Total Slide Count**
   Ask the user how many slides they want in total:
   - **5 slides**: Quick presentation (5 minutes)
   - **5-10 slides**: Standard presentation (10-15 minutes)
   - **10-15 slides**: Detailed presentation (20-30 minutes)
   - **20-25 slides**: Comprehensive presentation (45-60 minutes)

4. **Select Resolution**
   Ask user to choose resolution:
   - **2K**: Recommended, balanced quality and speed (~30s per slide)
   - **4K**: High quality, slower generation (~60s per slide, Pro model only)

### Phase 2: Analyze Document and Plan Content with Fine-Grained Allocation

**Important**: This phase implements fine-grained page control, allowing users to allocate pages per chapter.

1. **Analyze Document Structure**
   - Identify chapters/sections from document (look for markdown headers `#`, `##`)
   - Extract titles and key content for each section
   - Estimate content density and importance

2. **Calculate Automatic Allocation**
   Based on the selected total slide count, automatically calculate page distribution:

   - Reserve special pages:
     - Cover: 1 page (always)
     - Summary/Conclusion: 1-2 pages (for 10+ slides)

   - Allocate remaining pages to chapters proportionally based on:
     - Content length (longer chapters get more pages)
     - Section importance (can be inferred or equal weight)

   **Example for 15 slides total:**
   ```
   Total: 15 slides
   Reserved: Cover (1) + Summary (2) = 3 slides
   Available for content: 12 slides

   Chapters identified:
   - Chapter 1 "Introduction": 300 words → 2 pages (17%)
   - Chapter 2 "Core Concepts": 800 words → 5 pages (42%)
   - Chapter 3 "Implementation": 500 words → 3 pages (25%)
   - Chapter 4 "Case Studies": 400 words → 2 pages (17%)

   Total: 1 (cover) + 2 + 5 + 3 + 2 + 2 (summary) = 15 slides ✓
   ```

3. **Present Allocation and Ask User Preference**

   Show the automatic allocation to the user:
   ```
   建议的页数分配（共 15 页）:
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   封面: 1 页

   第1章 "Introduction": 2 页 (17%)
   第2章 "Core Concepts": 5 页 (42%)
   第3章 "Implementation": 3 页 (25%)
   第4章 "Case Studies": 2 页 (17%)

   总结: 2 页
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   总计: 15 页 ✓
   ```

   Then ask user using AskUserQuestion tool:
   ```
   Question: "请选择页数分配方式"
   Header: "页数分配"
   Options:
   - Label: "接受自动分配" (推荐)
     Description: "使用上述自动计算的页数分配"
   - Label: "自定义每章页数"
     Description: "手动指定每章的页数"
   ```

4. **If User Chooses Custom Allocation**

   For each chapter, ask the user how many slides to allocate:

   ```
   第1章 "Introduction" 分配多少页?
   (建议: 2 页, 剩余可分配: 12 页)
   > [Wait for user input]

   第2章 "Core Concepts" 分配多少页?
   (建议: 5 页, 剩余可分配: 10 页)
   > [Wait for user input]

   ... (continue for all chapters)

   验证:
   封面(1) + 第1章(2) + 第2章(5) + 第3章(3) + 第4章(2) + 总结(2) = 15 ✓
   ```

   - Keep track of remaining slides
   - Validate that total matches the requested slide count
   - If total doesn't match, ask user to re-allocate

5. **Generate Detailed Content Plan**

   Create detailed content for each slide based on the allocation:

   - For each chapter with N pages:
     - Split chapter content into N logical parts
     - Determine page type for each slide (cover/content/data)
     - Extract relevant content for each slide

   **Page Type Selection Logic:**
   - Slide 1: Always `cover`
   - Last 1-2 slides: Usually `data` (for summary/conclusions)
   - Middle slides: Mostly `content`, use `data` for slides with charts/statistics

6. **Create slides_plan.json**

   Generate JSON with enhanced metadata:

   ```json
   {
     "metadata": {
       "title": "Presentation Title",
       "total_slides": 15,
       "style": "gradient-glass",
       "resolution": "2K",
       "allocation_strategy": "custom",  // or "automatic"
       "created_at": "2026-01-22T10:30:00Z"
     },
     "allocation": {
       "cover": 1,
       "chapters": [
         {
           "chapter_number": 1,
           "chapter_title": "Introduction",
           "slides_allocated": 2,
           "slide_numbers": [2, 3]
         },
         {
           "chapter_number": 2,
           "chapter_title": "Core Concepts",
           "slides_allocated": 5,
           "slide_numbers": [4, 5, 6, 7, 8]
         },
         {
           "chapter_number": 3,
           "chapter_title": "Implementation",
           "slides_allocated": 3,
           "slide_numbers": [9, 10, 11]
         },
         {
           "chapter_number": 4,
           "chapter_title": "Case Studies",
           "slides_allocated": 2,
           "slide_numbers": [12, 13]
         }
       ],
       "summary": 2
     },
     "slides": [
       {
         "slide_number": 1,
         "chapter": null,
         "page_type": "cover",
         "content": "Title: Presentation Title\nSubtitle: Subtitle"
       },
       {
         "slide_number": 2,
         "chapter": 1,
         "page_type": "content",
         "content": "Introduction - Part 1\n- Key point 1\n- Key point 2"
       },
       {
         "slide_number": 3,
         "chapter": 1,
         "page_type": "content",
         "content": "Introduction - Part 2\n- Details..."
       }
       // ... more slides
     ]
   }
   ```

   Save this to a file in the outputs directory.

### Phase 3: Generate PPT Images using MCP

**Important**: This plugin uses MCP (Model Context Protocol) for image generation.
The `nanobanana` MCP server must be configured (see `.mcp.json`).

For each slide in the slides_plan.json:

1. **Load Style Template**
   - Read the selected style file from `plugins/nanobanana-ppt/styles/`
   - Parse HTML comment to extract metadata
   - Extract "基础提示词模板" section (from `## 基础提示词模板` to `## 页面类型模板`)
   - Extract page-type specific templates from "页面类型模板" section

2. **Generate Prompt for Slide**
   - Start with base style template
   - Add page-type specific instructions (封面页/内容页/数据页)
   - Inject slide content
   - Ensure 16:9 aspect ratio instruction

   **Prompt Structure:**
   ```
   [Base Style Template from style file]

   [Page Type Specific Template]

   Slide Content:
   [Actual slide content from slides_plan.json]

   Technical Requirements:
   - Aspect Ratio: 16:9
   - Resolution: [user selected]
   - Format: PNG
   ```

3. **Call MCP generate_image Tool**

   **Critical**: Use the MCP tool provided by nanobanana server.

   Tool: `generate_image` (from nanobanana MCP server)

   Parameters:
   ```
   {
     "prompt": [generated prompt from step 2],
     "model_tier": "auto",  // Let MCP intelligently choose flash/pro
     "resolution": "2k",  // or "4k" based on user selection
     "aspect_ratio": "16:9",
     "output_path": "outputs/[TIMESTAMP]/images/slide-[number:02d].png",
     "n": 1
   }
   ```

   **MCP Model Selection**:
   - `model_tier: "auto"`: MCP will automatically choose:
     - Flash model: For speed, standard quality
     - Pro model: For 4K resolution, quality keywords in prompt
   - Resolution mapping:
     - User selects "2K" → `resolution: "2k"`
     - User selects "4K" → `resolution: "4k"` (requires Pro model)

4. **Save Metadata**
   - For each generated image, record:
     - Slide number
     - Prompt used
     - Image path
     - Generation timestamp
     - Model tier used
   - Save all metadata to `outputs/[TIMESTAMP]/prompts.json`

5. **Progress Tracking**
   Display progress to user:
   ```
   正在生成第 1/15 页... ✓
   正在生成第 2/15 页... ✓
   正在生成第 3/15 页... ✓
   ...
   ```

   Handle errors gracefully:
   - If a slide fails, log the error
   - Ask user if they want to retry
   - Continue with remaining slides

6. **Generate HTML Viewer**
   - Use template from `plugins/nanobanana-ppt/templates/viewer.html`
   - Inject list of generated image paths
   - Save to `outputs/[TIMESTAMP]/index.html`

### Phase 4: Report Results

After generation completes, inform the user with a clear summary:

```
✅ PPT 生成成功！

📊 生成统计:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
总页数: 15 页
风格: 渐变毛玻璃卡片风格
分辨率: 2K (2752x1536)
用时: ~7.5 分钟

📁 输出位置:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
输出目录: outputs/20260122_103000/
图片目录: outputs/20260122_103000/images/
播放器: outputs/20260122_103000/index.html
提示词日志: outputs/20260122_103000/prompts.json

🎬 查看演示文稿:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
打开浏览器访问: outputs/20260122_103000/index.html

或使用命令:
open outputs/20260122_103000/index.html

播放器快捷键:
→ / ← : 切换幻灯片
↑ Home / ↓ End : 跳到首页/尾页
Space : 暂停/继续自动播放
ESC : 全屏模式
H : 隐藏/显示控件
```

Include chapter allocation breakdown if custom allocation was used:
```
📋 页数分配:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
封面: 1 页
第1章 "Introduction": 2 页 (第2-3页)
第2章 "Core Concepts": 5 页 (第4-8页)
第3章 "Implementation": 3 页 (第9-11页)
第4章 "Case Studies": 2 页 (第12-13页)
总结: 2 页 (第14-15页)
```

## Error Handling

### Common Errors and Solutions

1. **MCP Server Not Configured**
   ```
   Error: nanobanana MCP server not found
   Solution:
   - Ensure .mcp.json is configured in plugin directory
   - Verify uvx is installed: pip install uv
   - Run setup: /nanobanana-ppt:setup
   ```

2. **API Key Not Set**
   ```
   Error: GEMINI_API_KEY environment variable not set
   Solution:
   export GEMINI_API_KEY='your-api-key'
   Get key from: https://makersuite.google.com/app/apikey
   ```

3. **MCP Tool Call Failed**
   ```
   Error: generate_image tool failed
   Solution:
   - Check MCP server is running
   - Verify API key is valid
   - Check network connection
   - Retry the failed slide
   ```

4. **Invalid Allocation**
   ```
   Error: Total allocated pages don't match requested count
   Solution: Re-calculate or ask user to adjust allocation
   ```

## Best Practices

1. **Document Quality**: Well-structured input documents with clear sections produce better presentations
2. **Chapter Allocation**: For documents with uneven chapter lengths, use custom allocation
3. **Style Selection**: Choose style based on presentation context:
   - `gradient-glass`: Tech, business, data-heavy presentations
   - `vector-illustration`: Education, storytelling, creative content
4. **Resolution**:
   - Use 2K for daily presentations and online sharing
   - Use 4K for printing or large displays
5. **Review Generated Plan**: Before generation, show user the complete slides_plan.json outline
6. **Metadata Logging**: Always save prompts.json for reproducibility and debugging

## Technical Details

### MCP Integration
- **Server**: nanobanana-pro-mcp-server
- **Tools Used**: `generate_image`
- **Configuration**: `.claude-plugin/.mcp.json`
- **Authentication**: GEMINI_API_KEY environment variable

### Model Selection (via MCP)
- **Flash Model** (gemini-2.5-flash-image):
  - Speed: ~2-3 seconds per image
  - Max resolution: 1024px
  - Use case: Rapid prototyping, 2K output

- **Pro Model** (gemini-3-pro-image):
  - Speed: ~5-8 seconds per image
  - Max resolution: 4K (3840px)
  - Special features: Google Search grounding, advanced reasoning
  - Use case: High-quality output, text rendering, 4K resolution

### Output Structure
```
outputs/[TIMESTAMP]/
├── images/
│   ├── slide-01.png
│   ├── slide-02.png
│   └── ... (slide-NN.png)
├── slides_plan.json    # Content plan with allocation metadata
├── prompts.json        # Generation prompts and metadata
└── index.html          # HTML5 viewer
```

## Progressive Disclosure

Start with essential questions in order:
1. "What document would you like to convert to a PPT?"
2. "How many slides do you need? (5, 10, 15, or 20+)"
3. "Which style? (gradient-glass for modern/tech, vector-illustration for warm/creative)"
4. "Resolution? (2K faster, 4K higher quality)"

After document analysis:
5. Show automatic page allocation
6. Ask: "Accept automatic allocation or customize per chapter?"
7. If customize: Ask for page count per chapter

Only request additional details if necessary.

## Tool Requirements

This skill requires:
- **MCP Access**: nanobanana MCP server must be configured
- **File System Access**: To read documents and save outputs
- **Environment Variables**: GEMINI_API_KEY

This skill uses:
- **MCP Tools**: `generate_image` from nanobanana server
- **Claude Tools**: Read, Write, AskUserQuestion

Do NOT:
- Call Google Gemini API directly (use MCP instead)
- Skip the allocation planning phase
- Generate images without MCP tools

## Example Usage Scenarios

### Scenario 1: Quick 5-Slide PPT

**User Request:**
"Generate a 5-slide PPT from my meeting notes using gradient glass style, 2K."

**Skill Execution:**
1. Read meeting notes
2. Confirm: 5 slides, gradient-glass, 2K
3. Auto-allocate: Cover(1) + 3 content slides + Summary(1)
4. User accepts automatic allocation
5. Generate slides via MCP
6. Report results

### Scenario 2: 15-Slide with Custom Allocation

**User Request:**
"Create a 15-slide presentation from my product roadmap. I want more slides on implementation."

**Skill Execution:**
1. Read product roadmap document
2. Identify 4 chapters
3. Show automatic allocation:
   - Intro: 2 slides
   - Planning: 3 slides
   - Implementation: 4 slides
   - Launch: 3 slides
4. User chooses "customize"
5. User adjusts:
   - Intro: 2 slides
   - Planning: 2 slides
   - Implementation: 7 slides (increased)
   - Launch: 2 slides
   - Summary: 2 slides
6. Validate: Total = 15 ✓
7. Generate slides via MCP with custom allocation
8. Report results with allocation breakdown

## Version History

**v2.0** (2026-01-22):
- ✨ MCP integration for image generation
- ✨ Fine-grained page allocation (per-chapter control)
- ✨ Enhanced metadata in slides_plan.json
- ✨ Plugin-style dynamic style system
- 🔄 Removed direct google-genai SDK dependency
- 🔄 Updated for marketplace repository structure

**v1.0** (2026-01-11):
- Initial release with direct SDK integration
