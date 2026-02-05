---
name: styles
description: List and preview available PPT visual styles
---

# Styles Command

View all available visual styles for PPT generation and their characteristics.

## Available Styles

The following styles are currently available in `${CLAUDE_PLUGIN_ROOT}/styles/`:

Run the list-styles script to see all available styles:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/list-styles.sh
```

This will display:
- Style ID (for specifying in generation)
- Style Name
- Tags (keywords describing the style)
- Use Cases (recommended scenarios)

## How to Use Styles

When generating a PPT, specify your preferred style:

**By Style ID**:
```
使用 gradient-glass 风格生成PPT
```

**By Description**:
```
生成一个极简风格的PPT
```
The system will match your description to available styles.

**No Style Specified**:
```
生成一个15页的PPT
```
The system will prompt you to choose from available styles.

## Style Selection Tips

### For Tech/Business Content
✅ **gradient-glass**: Modern, 3D, professional
- Great for product launches
- Excellent for data visualization
- High-end aesthetic with glassmorphism

### For Minimal/Clean Design
✅ **linear-web**: Minimalist, flat, Swiss design
- Perfect for startups
- Clean geometric layouts
- Modern sans-serif typography

### For Education/Creative Content
✅ **vector-illustration**: Warm, flat, retro
- Friendly and approachable
- Great for storytelling
- Works well with diverse audiences

## Creating Custom Styles

You can create your own custom styles:

1. **Create a new file** in the `styles/` directory:
   ```bash
   cp styles/linear-web.md styles/my-custom-style.md
   ```

2. **Edit the style definition** with these required sections:
   ```markdown
   <!--
   风格元数据(必填)
   style_id: my-custom-style
   style_name: 我的自定义风格
   tags: tag1, tag2, tag3
   use_cases: use-case1, use-case2
   -->

   # 风格名称

   ## 风格ID
   my-custom-style

   ## 基础提示词模板
   [详细的AI绘画提示词...]

   ## 页面类型模板
   ### 封面页模板
   [封面页构图说明...]

   ### 内容页模板
   [内容页构图说明...]

   ### 数据页模板
   [数据页构图说明...]
   ```

3. **Run the list-styles script** to verify:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/list-styles.sh
   ```

4. **Use your custom style**:
   The system will automatically detect it and offer it as an option

## Resolution Recommendations

### For All Styles
- **2K** (recommended): Balanced quality and speed, ~30s per slide
- **4K** (high quality): Best for printing or large displays, ~60s per slide

### When to Use 4K
- Large screen presentations
- Printed materials
- High-detail visual styles (e.g., 3D, gradients)
- Portfolio or showcase pieces

### When to Use 2K
- Daily presentations
- Screen sharing (Zoom, Teams)
- Quick turnaround needed
- Online distribution

## Style Comparison

Different styles excel in different scenarios:

| Style | Best For | Mood | Complexity |
|-------|----------|------|------------|
| gradient-glass | Tech, business, data | Modern, futuristic | High (3D) |
| linear-web | Startups, portfolios | Minimal, clean | Medium |
| vector-illustration | Education, stories | Warm, friendly | Low (flat) |

Choose based on your:
- **Audience**: Corporate vs casual vs creative
- **Content**: Data-heavy vs conceptual vs narrative
- **Context**: Launch vs training vs pitch

## Preview Styles

To see examples of each style:

**Option 1: Generate Test Decks**
```bash
/nanobanana-ppt:generate
Create a 3-slide test presentation about "AI Technology"
Choose different styles to compare
```

**Option 2: Review Style Files**
```bash
ls -la ${CLAUDE_PLUGIN_ROOT}/styles/
cat ${CLAUDE_PLUGIN_ROOT}/styles/gradient-glass.md
cat ${CLAUDE_PLUGIN_ROOT}/styles/linear-web.md
cat ${CLAUDE_PLUGIN_ROOT}/styles/vector-illustration.md
```

**Option 3: Check Previous Outputs**
```bash
ls -la outputs/
```

## Dynamic Style Discovery

The plugin automatically discovers all styles in the styles directory.
No configuration needed - just add a new `.md` file and it will appear in the list!

To see all available styles at any time:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/list-styles.sh
```

---

Ready to create a presentation?

```
/nanobanana-ppt:generate
```

Choose your style and start generating!
