---
name: setup
description: Quick setup guide for the NanoBanana PPT plugin (v2.0 - MCP Edition)
---

# Setup Command

Set up the NanoBanana PPT plugin for generating professional presentations using MCP (Model Context Protocol).

## What's New in v2.0

🎉 **MCP Integration**: No more Python dependencies! This plugin now uses MCP for image generation.

## Quick Setup

This command will guide you through the setup process:

1. **Verify MCP server configuration**
2. **Install uvx** (if not already installed)
3. **Configure API key** (GEMINI_API_KEY)
4. **Test MCP connection**

## Prerequisites

You need:
- **Claude Code** with MCP support
- **uvx** (Python package runner)
- **Google AI API key**

**No Python dependencies required!** 🎉

## Get Your API Key

1. Visit: https://makersuite.google.com/app/apikey
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the key (starts with "AIza...")

## Installation Steps

### Step 1: Install uvx (if needed)

**Option A: Using pip**
```bash
pip install uv
```

**Option B: Using pipx (recommended)**
```bash
pipx install uv
```

**Verify installation:**
```bash
uvx --version
```

### Step 2: Verify MCP Configuration

The plugin includes a `.mcp.json` configuration file that Claude Code will automatically load:

```json
{
  "mcpServers": {
    "nanobanana": {
      "command": "uvx",
      "args": ["nanobanana-pro-mcp-server"],
      "env": {
        "GEMINI_API_KEY": "${GEMINI_API_KEY}"
      }
    }
  }
}
```

**No manual configuration needed!** Claude Code will detect this automatically.

### Step 3: Set API Key

**Option A: System Environment Variable (Recommended)**

For **zsh** users (macOS default):
```bash
echo 'export GEMINI_API_KEY="your-api-key-here"' >> ~/.zshrc
source ~/.zshrc
```

For **bash** users:
```bash
echo 'export GEMINI_API_KEY="your-api-key-here"' >> ~/.bashrc
source ~/.bashrc
```

For **fish** users:
```bash
set -Ux GEMINI_API_KEY "your-api-key-here"
```

**Option B: Session Variable (Temporary)**

```bash
export GEMINI_API_KEY="your-api-key-here"
```

Note: This only lasts for the current terminal session.

**Verify:**
```bash
echo $GEMINI_API_KEY  # Should display your API key
```

### Step 4: Test MCP Connection

Test that the MCP server can connect:

```bash
# This will be tested automatically when you first use the plugin
# Claude Code will verify the nanobanana MCP server is accessible
```

## Test Your Setup

After setup, try generating a test PPT:

```
/nanobanana-ppt:generate

Test content:
# My First Presentation
- Point 1: MCP setup complete
- Point 2: No Python dependencies needed
- Point 3: Ready to generate amazing slides!
```

Select:
- **Style**: gradient-glass
- **Slides**: 5
- **Resolution**: 2K

## What Happened to Python Dependencies?

**v1.0** (Old way):
- ❌ Required: `pip install google-genai pillow`
- ❌ Python environment management
- ❌ Dependency conflicts

**v2.0** (New way):
- ✅ MCP handles everything
- ✅ No Python dependencies
- ✅ Cleaner installation
- ✅ Automatic model selection (Flash/Pro)

The MCP server (`nanobanana-pro-mcp-server`) is installed automatically via `uvx` when first used.

## Security Best Practices

✅ **DO:**
- Store API key in environment variables
- Use `.env` files with `.gitignore`
- Rotate API keys periodically
- Use separate keys for different projects

❌ **DON'T:**
- Hardcode API keys in scripts
- Commit API keys to version control
- Share API keys in screenshots or logs
- Use API keys in client-side code

## Troubleshooting

### "uvx command not found"

**Install uv:**
```bash
pip install uv
# or
pipx install uv
```

### "MCP server not found"

1. Check uvx is installed: `uvx --version`
2. Verify API key is set: `echo $GEMINI_API_KEY`
3. Try manually installing the MCP server:
   ```bash
   uvx nanobanana-pro-mcp-server --version
   ```
4. Restart Claude Code

### "API key not working"

1. Check the key is correct (no extra spaces)
2. Verify it's set: `echo $GEMINI_API_KEY`
3. Try creating a new key at https://makersuite.google.com/app/apikey
4. Restart your terminal after setting the variable

### "MCP tool call failed"

1. Check network connection
2. Verify API key has quota remaining
3. Check MCP server logs in Claude Code
4. Try restarting Claude Code

### "Permission denied"

Make sure your terminal has permission to run `uvx`:
```bash
which uvx
# Should show the path to uvx
```

## MCP Server Details

The plugin uses the **nanobanana-pro-mcp-server** which provides:

- 🎨 **generate_image**: AI-powered image generation
  - Auto model selection (Flash/Pro)
  - 2K and 4K resolution support
  - 16:9 aspect ratio for presentations

- 📁 **upload_file**: File management via Gemini Files API
- 📊 **show_output_stats**: Track generated images
- 🔧 **maintenance**: Cleanup and quota management

All tools are called automatically by the plugin skill.

## Migration from v1.0

If you used the old version:

**Uninstall old Python dependencies (optional):**
```bash
pip uninstall google-genai pillow
```

**Remove old installation:**
```bash
/plugin uninstall nanobanana-ppt  # if installed as plugin
```

**Install new version:**
```bash
/plugin install https://github.com/qso/claude-plugins-qso?path=plugins/nanobanana-ppt
```

**That's it!** The new version works through MCP.

## Next Steps

After setup is complete:

1. ✨ Try `/nanobanana-ppt:generate` with a sample document
2. 🎨 Explore styles in the `styles/` directory
3. 📊 Test the new fine-grained page allocation feature
4. 🎬 Customize styles by editing `.md` files
5. 📖 Read the updated README for v2.0 features

## Getting Help

Need assistance?

- 📚 Check [README.md](../README.md) for detailed documentation
- 🎨 Review [styles/README.md](../styles/README.md) for style guide
- 📝 See [CHANGELOG.md](../CHANGELOG.md) for version history
- 💬 Visit: https://github.com/qso/claude-plugins-qso/issues

## Feature Highlights (v2.0)

🎯 **New Features:**
- ⚡ **MCP Integration**: Seamless image generation through Model Context Protocol
- 📊 **Fine-grained Page Control**: Allocate pages per chapter/section
- 🎨 **Dynamic Style System**: Plugin-style expandable styles
- 🚀 **No Python Dependencies**: Everything handled by MCP
- 🤖 **Auto Model Selection**: MCP intelligently chooses Flash/Pro models
- 📐 **Enhanced Metadata**: Detailed slides_plan.json with allocation info

---

✅ **Ready to start?**

Run:
```
/nanobanana-ppt:generate your-document.md
```

And follow the interactive prompts!
