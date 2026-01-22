# Changelog

All notable changes to the NanoBanana PPT plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-01-22

### 🎉 Major Release - MCP Integration

This is a major breaking change release that restructures the plugin for the new claude-plugins-qso marketplace and introduces MCP-based image generation.

### ⚠️ Breaking Changes

- **Project restructured**: Plugin moved from standalone repository to `claude-plugins-qso` marketplace
- **MCP integration**: Removed direct `google-genai` SDK dependency, now uses MCP for all image generation
- **Installation path changed**: New installation URL required
- **Repository URL**: `github.com/qso/NanoBanana-PPT-Skills` → `github.com/qso/claude-plugins-qso`

### ✨ Added

- **MCP Integration**: Complete migration to Model Context Protocol
  - Uses `nanobanana-pro-mcp-server` for image generation
  - Automatic model selection (Flash/Pro)
  - No Python dependencies required
  - Cleaner architecture with MCP tools

- **Fine-grained Page Allocation**: New per-chapter slide control
  - Automatic page distribution based on content length
  - Interactive custom allocation mode
  - User can specify exact pages per chapter
  - Enhanced `slides_plan.json` with allocation metadata

- **Plugin-style Dynamic Style System**:
  - Style metadata in HTML comments (no YAML frontmatter required)
  - Dynamic style discovery and loading
  - Styles can be added without code changes
  - `styles/README.md` index for easy navigation

- **Enhanced Documentation**:
  - Comprehensive SKILL.md rewrite with MCP workflows
  - Updated setup.md for MCP-based installation
  - New CHANGELOG.md for version tracking
  - Improved README with v2.0 features

### 🔄 Changed

- **Repository Structure**: From standalone plugin to marketplace plugin at `plugins/nanobanana-ppt/`
- **Plugin Configuration**: Updated `plugin.json` to v2.0 with MCP requirements
- **Skill Workflow**: Complete rewrite to use MCP tools instead of direct SDK calls
- **Style Files**: Added metadata comments to `gradient-glass.md` and `vector-illustration.md`
- **Installation Method**: Now uses marketplace URL with `?path=plugins/nanobanana-ppt`

### 🗑️ Removed

- **Python Dependency**: `google-genai` library no longer required
- **Python Dependency**: `pillow` library no longer required (still optional for local processing)
- **Direct SDK Calls**: All replaced with MCP tool calls
- **generate_ppt.py**: Script execution logic moved to Skill MCP calls

### 🐛 Fixed

- Simplified installation process (no more Python dependency issues)
- Better error handling through MCP layer
- More consistent model selection via MCP auto mode

### 📋 Migration Guide

#### For Users

**Old Installation (v1.0)**:
```bash
git clone https://github.com/qso/NanoBanana-PPT-Skills.git
pip install google-genai pillow
export GEMINI_API_KEY='...'
```

**New Installation (v2.0)**:
```bash
/plugin install https://github.com/qso/claude-plugins-qso?path=plugins/nanobanana-ppt
pip install uv  # Only uvx needed
export GEMINI_API_KEY='...'
```

#### For Developers

- Update repository URL in bookmarks
- Review new `.mcp.json` configuration
- Check updated SKILL.md for workflow changes
- Note: Python scripts no longer called directly

---

## [1.0.0] - 2026-01-11

### Initial Release

First public release of NanoBanana PPT plugin (standalone repository).

### Features

- **Direct SDK Integration**: Uses `google-genai` Python SDK
- **Two Visual Styles**:
  - Gradient glass card style
  - Vector illustration style
- **Multiple Resolutions**: 2K and 4K support
- **HTML5 Viewer**: Interactive presentation viewer
- **Slash Commands**: `/nanobanana-ppt:generate`, `/nanobanana-ppt:setup`, `/nanobanana-ppt:styles`
- **Skills Integration**: AI-driven PPT generation from documents

### Technical Details

- Model: `gemini-3-pro-image-preview`
- Python 3.8+ required
- Dependencies: `google-genai`, `pillow`
- Output: PNG images + HTML viewer

---

## Version Comparison

| Feature | v1.0.0 | v2.0.0 |
|---------|--------|--------|
| **Image Generation** | Direct SDK | MCP |
| **Python Dependencies** | Required | Optional |
| **Installation** | Manual | Plugin URL |
| **Model Selection** | Manual | Auto (MCP) |
| **Page Allocation** | Fixed | Fine-grained |
| **Style System** | Static | Dynamic |
| **Repository** | Standalone | Marketplace |

---

## Unreleased

### Planned Features

- [ ] Additional built-in styles (corporate, academic, creative)
- [ ] Template customization UI
- [ ] Batch generation support
- [ ] Export to PDF directly
- [ ] Multi-language support enhancements
- [ ] Animation effects in HTML viewer

### Under Consideration

- [ ] Voice narration integration
- [ ] Collaborative editing features
- [ ] Cloud storage integration
- [ ] Mobile app viewer

---

## Support

For bug reports and feature requests, please visit:
- **Issues**: https://github.com/qso/claude-plugins-qso/issues
- **Discussions**: https://github.com/qso/claude-plugins-qso/discussions

---

**Legend**:
- ✨ Added
- 🔄 Changed
- 🐛 Fixed
- 🗑️ Removed / Deprecated
- ⚠️ Breaking Change
- 📋 Documentation
