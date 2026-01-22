---
description: Generate a professional PPT presentation from a document using AI
---

# Generate PPT Command

Generate a professional PowerPoint-style presentation from a document using Google Nano Banana Pro AI image generation.

## Usage

```
/nanobanana-ppt:generate [document-path]
```

If no document path is provided, you will be prompted to provide one.

## What This Command Does

1. **Reads Your Document**: Analyzes the content structure and key points
2. **Plans Slides**: Intelligently organizes content into slides based on your chosen count
3. **Selects Style**: Choose from gradient glass (modern/tech) or vector illustration (warm/creative)
4. **Generates Images**: Uses AI to create high-quality 16:9 slide images
5. **Creates Viewer**: Generates an HTML5 viewer with keyboard navigation

## Interactive Prompts

You will be asked to choose:

1. **Number of slides**:
   - 5 slides: Quick presentation (5 minutes)
   - 5-10 slides: Standard presentation (10-15 minutes)
   - 10-15 slides: Detailed presentation (20-30 minutes)
   - 20-25 slides: Comprehensive presentation (45-60 minutes)

2. **Visual style**:
   - **Gradient Glass**: High-end gradient glass card style with 3D objects, neon gradients, cinematic lighting. Perfect for tech products, business presentations, data reports.
   - **Vector Illustration**: Warm flat vector illustration with black outlines, retro colors, geometric simplification. Perfect for education, creative proposals, brand stories.

3. **Resolution**:
   - **2K (2752x1536)**: Recommended, balanced quality and speed (~30 seconds per slide)
   - **4K (5504x3072)**: High quality for printing and large displays (~60 seconds per slide)

## Requirements

Before using this command, ensure:

1. **Python 3.8+** is installed
2. **Dependencies** are installed: `pip install google-genai pillow`
3. **API Key** is set: `export GEMINI_API_KEY='your-api-key'`
   - Get your API key from: https://makersuite.google.com/app/apikey

## Examples

### Generate from a file
```
/nanobanana-ppt:generate my-document.md
```

### Generate with inline content
```
/nanobanana-ppt:generate

I want to create a presentation about AI Product Design with these points:
- Introduction to AI UX
- Design Principles
- Case Studies
- Future Trends
```

### Typical workflow
```
User: /nanobanana-ppt:generate product-roadmap.md
AI: I'll help you generate a PPT from product-roadmap.md. How many slides would you like? (5/10/15/20+)
User: 10
AI: Which style? 1) Gradient Glass (modern/tech) or 2) Vector Illustration (warm/creative)
User: 1
AI: Resolution? 1) 2K (faster) or 2) 4K (higher quality)
User: 1
AI: [Analyzes document, plans 10 slides, generates images, provides viewer path]
```

## Output

After generation, you'll receive:

- **Output directory** with timestamped folder
- **Image files** (slide-01.png, slide-02.png, etc.)
- **HTML viewer** with keyboard navigation and fullscreen support
- **Prompts log** (prompts.json) for reference

### Viewer Controls

- `←` `→` : Navigate slides
- `↑` `Home` : Jump to first slide
- `↓` `End` : Jump to last slide
- `Space` : Pause/resume autoplay
- `ESC` : Toggle fullscreen
- `H` : Hide/show controls

## Tips

✅ **Good documents** for conversion:
- Well-structured markdown with clear headings
- Documents with 2-5 main sections
- Content with bullet points and key takeaways

✅ **Best practices**:
- Use 2K resolution for daily presentations
- Use 4K for printing or large displays
- Choose slide count based on presentation time (1 minute per slide guideline)
- Review the generated prompts.json to understand how content was interpreted

## Troubleshooting

**"API key not set"**
→ Run: `export GEMINI_API_KEY='your-key'`

**"Dependencies missing"**
→ Run: `pip install google-genai pillow`

**Generation takes too long**
→ This is normal. 2K: ~30s/slide, 4K: ~60s/slide. A 10-slide deck takes 5-10 minutes.

**Want to regenerate with changes**
→ Edit the slides_plan.json file and run the Python script directly with custom parameters.

---

Now analyze the document $ARGUMENTS and help the user create a professional presentation.

If no document is provided in $ARGUMENTS, ask the user to provide a document path or paste the content directly.

