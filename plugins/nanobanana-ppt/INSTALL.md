# Installation Guide for NanoBanana PPT Plugin

This guide covers all methods to install and use the NanoBanana PPT plugin for Claude Code.

## Prerequisites

Before installing, ensure you have:

1. **Claude Code v1.0.33 or later**
   ```bash
   claude --version
   ```

2. **Python 3.8+** (for MCP server)
   ```bash
   python --version
   ```

3. **Gemini API Key** from [Google AI Studio](https://makersuite.google.com/app/apikey)

## Installation Methods

### Method 1: From GitHub Marketplace (Recommended)

This is the easiest way for end users to install the plugin.

```bash
# 1. Add the QSO plugins marketplace
/plugin marketplace add qso/claude-plugins-qso

# 2. Install the plugin
/plugin install nanobanana-ppt@claude-plugins-qso

# 3. The plugin will be installed to user scope by default
```

**Installation Scopes:**
- **User scope** (default): Available across all your projects
- **Project scope**: Shared with team via `.claude/settings.json`
- **Local scope**: Only for you in this project

To choose a different scope, use the interactive UI:
```bash
/plugin
# Navigate to Discover → nanobanana-ppt → Press Enter → Select scope
```

### Method 2: Local Development Install

For plugin development or testing local changes:

```bash
# 1. Add the local marketplace
/plugin marketplace add /Users/hzlizhaoming/Project/claude-plugins-qso

# 2. Install from local source
/plugin install nanobanana-ppt@claude-plugins-qso
```

**Alternative: Direct Symlink** (for active development)
```bash
# Create a symlink in Claude's plugin directory
ln -s /Users/hzlizhaoming/Project/claude-plugins-qso/plugins/nanobanana-ppt \
      ~/.claude/plugins/nanobanana-ppt
```

### Method 3: Team/Project Configuration

For teams, add to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": [
    {
      "name": "claude-plugins-qso",
      "source": "qso/claude-plugins-qso"
    }
  ],
  "enabledPlugins": [
    "nanobanana-ppt@claude-plugins-qso"
  ]
}
```

Team members will be prompted to install when they trust the repository folder.

## Configuration

### 1. Set Environment Variable

The plugin requires a Gemini API key to function:

```bash
# Set for current session
export GEMINI_API_KEY='your-api-key-here'

# Make it permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export GEMINI_API_KEY="your-api-key-here"' >> ~/.zshrc
source ~/.zshrc
```

**Get your API key:**
1. Visit https://makersuite.google.com/app/apikey
2. Create a new API key
3. Copy and set it in your environment

### 2. Verify MCP Server

The plugin uses the `nanobanana-pro-mcp-server` via `uvx`. Verify it's accessible:

```bash
# Test uvx is available
uvx --version

# Test the MCP server (should show help or version info)
uvx nanobanana-pro-mcp-server --help
```

## Verification

### 1. Check Plugin Status

```bash
# List all installed plugins
/plugin list

# Check MCP servers
/mcp
```

You should see:
- `nanobanana-ppt` in the plugin list
- `nanobanana` MCP server in the MCP list

### 2. Test Commands

Try the available commands:

```bash
# View setup instructions
/setup

# List available visual styles
/styles

# Generate a presentation
/generate path/to/document.md
```

### 3. Test Skill Activation

The plugin includes a skill that activates automatically:

```
"Help me create a PPT presentation from this document..."
```

Claude should automatically use the PPT generator skill.

## Troubleshooting

### Plugin Not Found

**Symptom:** `/plugin install` says plugin not found

**Solutions:**
1. Verify marketplace is added: `/plugin marketplace list`
2. Update marketplace: `/plugin marketplace update claude-plugins-qso`
3. Check repository is public and accessible

### MCP Server Not Starting

**Symptom:** Commands work but image generation fails

**Solutions:**
1. Check API key is set: `echo $GEMINI_API_KEY`
2. Verify uvx is installed: `which uvx`
3. Test MCP server manually: `uvx nanobanana-pro-mcp-server`
4. Check Claude Code logs: `claude --debug`

### Environment Variable Not Found

**Symptom:** Error about missing GEMINI_API_KEY

**Solutions:**
1. Set in current terminal: `export GEMINI_API_KEY='your-key'`
2. Add to shell profile: `~/.bashrc` or `~/.zshrc`
3. Restart terminal after adding to profile
4. Verify with: `echo $GEMINI_API_KEY`

### Commands Not Appearing

**Symptom:** `/generate`, `/setup`, `/styles` not recognized

**Solutions:**
1. Verify plugin is enabled: `/plugin list` (should show ✓)
2. Enable if disabled: `/plugin enable nanobanana-ppt@claude-plugins-qso`
3. Restart Claude Code
4. Check command prefix: may be `/nanobanana-ppt:generate`

### Skill Not Activating

**Symptom:** Skill doesn't trigger automatically

**Solutions:**
1. Use explicit trigger: "Use the ppt-generator skill to..."
2. Check skill is loaded: Look for skill in `/plugin` details
3. Clear plugin cache and reinstall:
   ```bash
   rm -rf ~/.claude/plugins/cache
   /plugin uninstall nanobanana-ppt@claude-plugins-qso
   /plugin install nanobanana-ppt@claude-plugins-qso
   ```

## Usage Examples

### Basic Usage

```bash
# 1. Generate from a markdown file
/generate ./docs/presentation.md

# 2. Interactive prompts will ask for:
#    - Number of slides (5, 10, 15, or 25)
#    - Visual style (gradient-glass or vector-illustration)
#    - Resolution (2K or 4K)

# 3. Wait for AI to generate images
#    - ~30 seconds per slide for 2K
#    - ~60 seconds per slide for 4K

# 4. Open the generated HTML viewer
#    - Located at: ./output/presentation/index.html
```

### Advanced Usage

```bash
# Check available styles first
/styles

# Get setup help
/setup

# Use skill for more control
"Create a 10-slide presentation from README.md using the gradient-glass style"
```

## Uninstallation

To remove the plugin:

```bash
# Disable (keeps configuration)
/plugin disable nanobanana-ppt@claude-plugins-qso

# Uninstall (removes completely)
/plugin uninstall nanobanana-ppt@claude-plugins-qso

# Remove marketplace (optional)
/plugin marketplace remove claude-plugins-qso
```

## Updates

### Auto-Update (Default)

Official marketplaces auto-update on Claude Code startup. Check for updates:

```bash
# Update marketplace listings
/plugin marketplace update claude-plugins-qso

# Updates will be installed automatically on next restart
```

### Manual Update

```bash
# Uninstall old version
/plugin uninstall nanobanana-ppt@claude-plugins-qso

# Install latest version
/plugin install nanobanana-ppt@claude-plugins-qso
```

### Disable Auto-Update

```bash
# Disable all auto-updates
export DISABLE_AUTOUPDATER=true

# Keep plugin updates but disable Claude Code updates
export DISABLE_AUTOUPDATER=true
export FORCE_AUTOUPDATE_PLUGINS=true
```

## Support

- **Issues:** https://github.com/qso/claude-plugins-qso/issues
- **Documentation:** https://github.com/qso/claude-plugins-qso/tree/main/plugins/nanobanana-ppt
- **Claude Code Docs:** https://code.claude.com/docs

## Next Steps

- Read the [README](./README.md) for usage details
- Check [CHANGELOG](./CHANGELOG.md) for version history
- Explore example documents in [examples/](./examples/)
- Customize styles in [styles/](./styles/)
