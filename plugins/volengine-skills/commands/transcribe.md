---
name: transcribe
description: Transcribe audio files to text using Volcengine ASR API
arguments:
  - name: audio_input
    description: The audio file (local path or public URL) to transcribe
    required: true
  - name: format
    description: Audio format (mp3, wav, ogg, raw)
    required: false
    default: mp3
  - name: language
    description: Language code (e.g., en-US, ja-JP, ko-KR). Leave empty for auto-detect
    required: false
    default: ""
  - name: poll_interval
    description: Seconds between polling attempts (default: 3)
    required: false
    default: "3"
  - name: output_dir
    description: Output directory for results (default: $CLAUDE_PROJECT_DIR/assets)
    required: false
    default: "$CLAUDE_PROJECT_DIR/assets"
---

# Transcribe Audio with Volcengine ASR

Transcribe audio files to text using ByteDance's Volcengine ASR API.

## Quick Start

### 1. Set API Credentials

```bash
export VOLCENGINE_API_APP_KEY='your-app-key'
export VOLCENGINE_API_ACCESS_KEY='your-access-key'
```

Get keys from: https://console.volcengine.com/openspeech

### 2. Transcribe Audio

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
# Default location
ls "$CLAUDE_PROJECT_DIR/assets/"
```

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

### Local Files

Auto-uploads to tmpfiles.org (max 100MB):

```bash
# Basic
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "/Users/username/Downloads/meeting.mp3"

# With format
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "~/Downloads/interview.wav" wav

# With language
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "/path/to/audio.mp3" mp3 "ja-JP"

# Custom output
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "/path/to/audio.mp3" mp3 "" 3 "$CLAUDE_PROJECT_DIR/podcasts"
```

### URLs

```bash
# Basic
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "https://example.com/audio.mp3"

# With format
bash "${CLAUDE_PLUGIN_ROOT}/skills/asr-transcriber/scripts/transcribe.sh" \
  "https://example.com/audio.wav" wav
```

## Supported Languages

**Auto-detect:** Chinese, English, dialects

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

## Input Requirements

### ✅ Local Files
- Max: 100MB
- Auto-uploads to tmpfiles.org
- Formats: MP3, WAV, OGG, RAW

### ✅ Public URLs
- HTTPS only
- Must be publicly accessible

### ❌ Won't Work
- Files > 100MB (upload manually to cloud storage first)
- Private URLs requiring authentication
- Non-HTTP protocols

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

## Processing Time

- 1 minute audio: ~5-10 seconds
- 10 minutes audio: ~30-60 seconds
- 1 hour audio: ~2-5 minutes

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

**Environment variables not set:**
```bash
export VOLCENGINE_API_APP_KEY='your-key'
export VOLCENGINE_API_ACCESS_KEY='your-secret'
```

**Output not found:**
```bash
ls "$CLAUDE_PROJECT_DIR/assets/"
```

**Files > 100MB:**
Upload manually to cloud storage or local server first.

## Best Practices

1. Use `${CLAUDE_PLUGIN_ROOT}` for script path
2. Output to `$CLAUDE_PROJECT_DIR/assets`
3. Start with mp3 format
4. Let language auto-detect unless certain
5. Check JSON output for detailed results with timestamps
