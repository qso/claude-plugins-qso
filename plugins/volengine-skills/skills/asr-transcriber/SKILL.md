---
name: asr-transcriber
description: Transcribe audio files to text using Volcengine ASR API scripts. Use this when the user wants to convert audio to text, transcribe recordings, or perform speech recognition on audio files.
---

# Volcengine ASR Transcriber Skill

Transcribe audio files to text using ByteDance's Volcengine ASR API.

## Important Paths

- **Script:** `${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh`
- **Output:** `$CLAUDE_PROJECT_DIR/assets/` (default, project root)

## Quick Start

### 1. Set API Credentials

```bash
export VOLCENGINE_API_APP_KEY='your-app-key'
export VOLCENGINE_API_ACCESS_KEY='your-access-key'
```

Get keys from: https://console.volcengine.com/openspeech

### 2. Transcribe

```bash
# From local file (auto-uploads to tmpfiles.org)
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "/path/to/audio.mp3"

# From URL
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "https://example.com/audio.mp3"

# With custom output directory
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "/path/to/audio.mp3" mp3 "" 3 "$CLAUDE_PROJECT_DIR/transcripts"
```

### 3. Find Output

```bash
# Check default location
ls "$CLAUDE_PROJECT_DIR/assets/"
```

## What It Does

1. **Local files:** Auto-uploads to tmpfiles.org (max 100MB)
2. **Model selection:** Tries Model 2.0, falls back to Model 1.0
3. **Submits** task to Volcengine API
4. **Polls** for results automatically (every 3s)
5. **Saves** to both JSON and TXT files

## Usage

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  <audio_input> [format] [language] [poll_interval] [output_dir]
```

**Arguments:**
- `audio_input`: URL or local path (required)
- `format`: mp3, wav, ogg, raw (default: mp3)
- `language`: Language code (default: auto-detect)
- `poll_interval`: Seconds between polls (default: 3)
- `output_dir`: Output directory (default: `$CLAUDE_PROJECT_DIR/assets`)

## Examples

```bash
# Local file with auto-upload
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "/Users/username/Downloads/meeting.mp3"

# URL with specific format
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "https://example.com/interview.wav" wav

# Specify language (Japanese)
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "/path/to/audio.mp3" mp3 "ja-JP"

# Custom output directory
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "/path/to/audio.mp3" mp3 "" 3 "$CLAUDE_PROJECT_DIR/podcasts"
```

## Supported Languages

**Auto-detect:** Chinese, English, dialects (Shanghainese, Cantonese, etc.)

**Specific:**
| Code    | Language |
|---------|----------|
| en-US   | English  |
| ja-JP   | Japanese |
| ko-KR   | Korean   |
| es-MX   | Spanish  |
| pt-BR   | Portuguese |
| de-DE   | German   |
| fr-FR   | French   |

## Supported Formats

- **mp3** (recommended)
- **wav**
- **ogg**
- **raw**

## Input Types

### ✅ Local Files
- Max: 100MB
- Auto-uploads to tmpfiles.org
- Formats: MP3, WAV, OGG, RAW

### ✅ Public URLs
- HTTPS only
- Must be publicly accessible

## Output

Two files saved to output directory:
- **JSON:** Full transcription with timestamps and metadata
- **TXT:** Plain text only

Naming: `{filename}_{timestamp}.{ext}`

Example:
```
$CLAUDE_PROJECT_DIR/assets/meeting_20260202_143022.json
$CLAUDE_PROJECT_DIR/assets/meeting_20260202_143022.txt
```

## Best Practices

✅ Use `${CLAUDE_PLUGIN_ROOT}` for script path
✅ Output to `$CLAUDE_PROJECT_DIR/assets`
✅ Start with mp3 format
✅ Let language auto-detect unless certain

❌ Don't output to plugin directory
❌ Don't use files > 100MB without manual upload

## Troubleshooting

**Script not found:**
```bash
cd "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts"
./transcribe.sh "URL"
```

**Permission denied:**
```bash
chmod +x "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/"*.sh
```

**Output not found:**
```bash
ls "$CLAUDE_PROJECT_DIR/assets/"
```

**Files > 100MB:**
Upload manually to cloud storage or local server first.
