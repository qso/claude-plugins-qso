---
description: List and preview available PPT visual styles
---

# Styles Command

View all available visual styles for PPT generation and their characteristics.

## Available Styles

### 1. Gradient Glass Card Style

**File**: `styles/gradient-glass.md`

**Visual Characteristics**:
- Apple Keynote minimalism with glassmorphism
- 3D glass objects with volumetric lighting
- Neon purple, electric blue, coral orange gradients
- Deep void black or ceramic white base
- Cinema-grade ray tracing and ambient occlusion
- Bento box grid layout with frosted glass containers

**Best For**:
- 🚀 Tech product launches
- 💼 Business presentations
- 📊 Data reports and analytics
- 🏢 Corporate brand showcases
- 💻 SaaS product demos

**Atmosphere**: Premium, immersive, clean, futuristic

**Example Elements**:
- Floating 3D capsules and geometric shapes
- Glowing neon charts and data visualizations
- Polished metal, iridescent acrylic materials
- Aurora wave backgrounds
- Cinematic lighting effects

### 2. Vector Illustration Style

**File**: `styles/vector-illustration.md`

**Visual Characteristics**:
- Flat vector illustration with uniform black outlines
- Geometric simplification (toy-like models)
- Retro soft color palette: coral red, mint green, mustard yellow
- Cream/off-white paper texture background
- Panoramic composition in top 1/3 of canvas
- Decorative geometric elements (dots, stars, rays)

**Best For**:
- 📚 Educational presentations and training
- 🎨 Creative proposals and pitches
- 👶 Children's content and family topics
- 💖 Warm brand storytelling
- 🌟 Community and social initiatives

**Atmosphere**: Warm, approachable, playful, nostalgic

**Example Elements**:
- Simplified buildings and trees with black outlines
- Retro serif typography for headlines
- Geometric icons and small illustrations
- Pill-shaped clouds and decorative elements
- Clean, coloring-book style line art

## Style Comparison

| Aspect | Gradient Glass | Vector Illustration |
|--------|----------------|---------------------|
| **Visual Style** | 3D, realistic, futuristic | 2D, flat, geometric |
| **Color Mood** | Bold, vibrant, high-tech | Soft, retro, warm |
| **Complexity** | High detail, cinematic | Simple, clean lines |
| **Use Case** | Tech, business, data | Education, creative, story |
| **Audience** | Professional, corporate | General, friendly, casual |
| **Rendering** | Photorealistic 3D | Vector graphics |

## How to Use Styles

When generating a PPT, you'll be prompted to choose a style:

```
/nanobanana-ppt:generate my-document.md
```

The system will ask:
```
Which style would you like?
1. Gradient Glass (modern/tech)
2. Vector Illustration (warm/creative)
```

## Creating Custom Styles

You can create your own custom styles:

1. **Create a new file** in the `styles/` directory:
   ```bash
   cp styles/gradient-glass.md styles/my-custom-style.md
   ```

2. **Edit the style definition** with these sections:
   - Style ID and name
   - Visual description
   - Base prompt template
   - Page type templates (cover, content, data)
   - Technical parameters

3. **Use your custom style**:
   The plugin will automatically detect and offer your new style

### Style Template Structure

```markdown
# Your Style Name

## Style ID
your-style-id

## Style Description
Brief description of the visual aesthetic

## Base Prompt Template
[Detailed prompt that defines the overall visual language]

## Page Type Templates

### Cover Page Template
Layout logic for title slides

### Content Page Template
Layout logic for content slides

### Data Page Template
Layout logic for data/summary slides

## Technical Parameters
- Model: gemini-3-pro-image-preview
- Aspect Ratio: 16:9
- Resolution: 2K or 4K
```

## Style Tips

### For Tech/Business Content
✅ Use **Gradient Glass** style
- Professional and modern
- Great for data visualization
- High-end aesthetic
- Works well with statistics and metrics

### For Education/Creative Content
✅ Use **Vector Illustration** style
- Friendly and approachable
- Easy to understand
- Works well with concepts and stories
- Great for diverse audiences

### Mixed Style Strategy

For longer presentations (15+ slides), consider:
1. Use Gradient Glass for data-heavy slides
2. Use Vector Illustration for concept/story slides
3. Generate two separate decks and combine manually

## Resolution Recommendations by Style

### Gradient Glass
- **2K**: Perfect for screen presentations
- **4K**: Recommended for large displays or printing (showcases 3D details)

### Vector Illustration
- **2K**: Usually sufficient (vector style scales well)
- **4K**: Only if printing or large format output

## Preview Styles

To see examples of each style:

1. Check the `outputs/` directory for any previously generated presentations
2. Review the style definition files directly:
   - `styles/gradient-glass.md`
   - `styles/vector-illustration.md`
3. Generate a small test deck (3-5 slides) in each style to compare

## Style Customization Tips

### Adjusting Gradient Glass
- Modify color gradients in the prompt
- Change 3D object types (capsules, spheres, waves)
- Adjust lighting intensity
- Change base color (dark vs light mode)

### Adjusting Vector Illustration
- Change color palette (keep retro/soft tones)
- Modify line thickness
- Add or remove decorative elements
- Adjust geometric simplification level

## Technical Details

Both styles use:
- **Model**: Gemini 3 Pro Image Preview (Nano Banana Pro)
- **Aspect Ratio**: 16:9 (standard presentation format)
- **Output Format**: PNG images
- **Generation Time**: 30-60 seconds per slide

---

Want to see these styles in action? Try:

```
/nanobanana-ppt:generate

Create a 3-slide test presentation about "AI Technology"
```

Then choose each style to compare the results!

