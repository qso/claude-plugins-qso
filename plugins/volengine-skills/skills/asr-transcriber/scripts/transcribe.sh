#!/bin/bash
#
# Volcengine ASR - Transcribe Wrapper Script
#
# This script combines submit and query operations for automatic transcription
#
# Usage:
#   ./transcribe.sh <audio_url> [format] [language] [poll_interval] [output_dir]
#
# Arguments:
#   audio_url     : URL of the audio file (required)
#   format        : Audio format - mp3, wav, ogg, raw (default: mp3)
#   language      : Language code (optional, default: auto-detect)
#   poll_interval : Seconds between polling attempts (default: 3)
#   output_dir    : Output directory for results (default: ./assets)
#
# Examples:
#   ./transcribe.sh "https://example.com/audio.mp3"
#   ./transcribe.sh "https://example.com/audio.wav" wav
#   ./transcribe.sh "https://example.com/audio.mp3" mp3 "en-US"
#   ./transcribe.sh "https://example.com/audio.mp3" mp3 "" 5
#   ./transcribe.sh "https://example.com/audio.mp3" mp3 "" 3 "./output"
#

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
POLL_INTERVAL="${4:-3}"
OUTPUT_DIR="${5:-./assets}"
MAX_ATTEMPTS=60  # 5 minutes max with 3s interval
SHOW_SPEAKER_INFO=false
SHOW_UTTERANCES=true

# Parse arguments
AUDIO_URL="$1"
FORMAT="${2:-mp3}"
LANGUAGE="${3:-}"

# Validate arguments
if [ -z "$AUDIO_URL" ]; then
    echo "❌ Error: Audio URL is required"
    echo ""
    echo "Usage: $0 <audio_url> [format] [language] [poll_interval] [output_dir]"
    echo ""
    echo "Arguments:"
    echo "  audio_url     : URL of the audio file (required)"
    echo "  format        : Audio format - mp3, wav, ogg, raw (default: mp3)"
    echo "  language      : Language code (optional)"
    echo "  poll_interval : Seconds between polling (default: 3)"
    echo "  output_dir    : Output directory for results (default: ./assets)"
    echo ""
    echo "Examples:"
    echo "  $0 \"https://example.com/audio.mp3\""
    echo "  $0 \"https://example.com/audio.wav\" wav"
    echo "  $0 \"https://example.com/audio.mp3\" mp3 \"en-US\""
    echo "  $0 \"https://example.com/audio.mp3\" mp3 \"\" 3 \"./output\""
    exit 1
fi

# Display configuration
echo "🎤 Volcengine ASR Transcription"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Audio URL: $AUDIO_URL"
echo "Format: $FORMAT"
if [ -n "$LANGUAGE" ]; then
    echo "Language: $LANGUAGE"
else
    echo "Language: Auto-detect"
fi
echo "Poll Interval: ${POLL_INTERVAL}s"
echo "Output Directory: $OUTPUT_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Submit task
echo "Step 1: Submitting transcription task..."
echo ""

if ! bash "$SCRIPT_DIR/submit_task.sh" "$AUDIO_URL" "$FORMAT" "$LANGUAGE" "$OUTPUT_DIR"; then
    echo ""
    echo "❌ Failed to submit task"
    exit 1
fi

# Get task ID from saved file
TASK_ID=$(cat /tmp/volcengine_last_task_id)
echo ""
echo "✓ Task submitted successfully"
echo ""

# Step 2: Poll for results
echo "Step 2: Polling for results..."
echo ""

ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))

    # Display progress
    echo -ne "\r⏳ Checking status... (Attempt $ATTEMPT/$MAX_ATTEMPTS) "

    # Query status
    STATUS_OUTPUT=$(bash "$SCRIPT_DIR/query_task.sh" "$TASK_ID" 2>&1)
    EXIT_CODE=$?

    # Check if complete
    if [ $EXIT_CODE -eq 0 ]; then
        echo ""
        echo ""
        echo "✅ Transcription completed!"
        echo ""

        # Display the full output
        bash "$SCRIPT_DIR/query_task.sh" "$TASK_ID"
        exit 0
    fi

    # Check if error (not processing/queued)
    if ! echo "$STATUS_OUTPUT" | grep -qE "(processing|queued|⏳|📋)"; then
        echo ""
        echo ""
        echo "❌ Error during polling:"
        echo "$STATUS_OUTPUT"
        exit 1
    fi

    # Wait before next poll
    sleep "$POLL_INTERVAL"
done

# Timeout
echo ""
echo ""
echo "❌ Timeout: Task did not complete within $((MAX_ATTEMPTS * POLL_INTERVAL)) seconds"
echo ""
echo "The task is still running. You can check manually later:"
echo "  ./query_task.sh \"$TASK_ID\""
exit 1
