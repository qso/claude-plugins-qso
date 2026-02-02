# ASR Transcriber - Changelog

All notable changes to the ASR Transcriber skill will be documented in this file.

## [1.1.0] - 2025-02-02

### Added ✨
- **Local file upload support**: Automatic upload to tmpfiles.org for files up to 100MB
- **Download URL conversion**: Automatically converts tmpfiles.org URLs to download URLs with `/dl/` prefix
- **Model fallback**: Automatically falls back from Model 2.0 to Model 1.0 if Model 2.0 is not available
- **Output directory flexibility**: Supports custom output directories with `$CLAUDE_PROJECT_DIR` variable
- **Test suite**: Comprehensive test scripts for local file and URL input validation
- **Documentation**: Complete SKILL.md and command documentation with Claude Code path variables

### Changed 🔄
- **Improved error handling**: Better error messages for upload failures and API errors
- **Streamlined documentation**: Reduced SKILL.md from 597 lines to 168 lines (72% reduction)
- **Streamlined command docs**: Reduced transcribe.md from 528 lines to 206 lines (61% reduction)
- **Better path handling**: Uses `${CLAUDE_PLUGIN_ROOT}` for script paths and `$CLAUDE_PROJECT_DIR` for outputs

### Fixed 🐛
- **URL variable bug**: Fixed submit_task.sh using wrong variable (`$AUDIO_URL` instead of `$INPUT_URL`)
- **Stdout/stderr mix**: Fixed debug messages corrupting URL capture by redirecting to stderr
- **File size display**: Fixed file size calculation showing 0MB for small files
- **Path confusion**: Clarified that outputs go to project directory, not plugin directory

### Technical Details
- Scripts now properly distinguish between local files and URLs using regex pattern matching
- Upload function uses stderr for progress messages to keep stdout clean for URL capture
- Default output directory is `$CLAUDE_PROJECT_DIR/assets` instead of relative `./assets`
- All examples updated to use Claude Code built-in variables

## [1.0.0] - 2025-01-XX

### Added ✨
- Initial release of ASR Transcriber skill
- Support for mp3, wav, ogg, and raw audio formats
- Automatic language detection (Chinese, English, dialects)
- Support for 10+ languages with explicit language codes
- JSON and TXT dual format output
- Timestamp and utterance segmentation
- Model 2.0 and Model 1.0 support
- Task submission and query scripts
- Automatic polling for transcription results

---

## Version Convention

- **Major**: Breaking changes or major new features
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes, documentation updates
