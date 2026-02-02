# Changelog

All notable changes to the Volcengine Skills plugin will be documented in this file.

## [1.0.0] - 2025-02-02

### Added ✨
- **Plugin rebranding**: Renamed from "volengine-asr" to "volengine-skills" to support multiple Volcengine AI capabilities
- **ASR Transcriber skill**: Complete audio-to-text transcription feature
  - Local file auto-upload to tmpfiles.org (max 100MB)
  - Public URL support
  - 10+ language support with auto-detection
  - Model 2.0/1.0 with automatic fallback
  - JSON and TXT dual format output
  - Timestamp and utterance segmentation
- **Test suite**: Comprehensive tests for local file and URL transcription
- **Documentation**:
  - Plugin README with multi-skill overview
  - ASR Skill documentation (SKILL.md)
  - Command reference (transcribe.md)
  - ASR CHANGELOG with detailed version history

### Changed 🔄
- **Plugin structure**: Reorganized as multi-skill plugin for future expansion
- **Path handling**: Uses Claude Code built-in variables (`${CLAUDE_PLUGIN_ROOT}`, `$CLAUDE_PROJECT_DIR`)
- **Documentation**: Streamlined and focused on essential information

### Fixed 🐛
- **Local file upload**: Fixed URL variable and stdout/stderr issues
- **Model fallback**: Automatic degradation from Model 2.0 to Model 1.0
- **Output directory**: Clarified project directory as default output location

---

## Future Plans

### Potential Skills 🚧
- TTS (Text-to-Speech)
- Translation
- Voice Analysis
- And more Volcengine AI capabilities...

---

## Version Convention

- **Major**: Breaking changes, major new features, or new skills
- **Minor**: New features within existing skills, backward compatible
- **Patch**: Bug fixes, documentation updates, test improvements
