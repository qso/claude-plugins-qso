#!/bin/bash
#
# Volcengine ASR - Submit Task Script
#
# Usage:
#   ./submit_task.sh <audio_url> [format] [language] [output_dir]
#
# Arguments:
#   audio_url  : URL of the audio file (required)
#   format     : Audio format - mp3, wav, ogg, raw (default: mp3)
#   language   : Language code (optional, default: auto-detect)
#   output_dir : Output directory for results (default: ./assets)
#
# Examples:
#   ./submit_task.sh "https://example.com/audio.mp3"
#   ./submit_task.sh "https://example.com/audio.wav" wav
#   ./submit_task.sh "https://example.com/audio.mp3" mp3 "en-US"
#   ./submit_task.sh "https://example.com/audio.mp3" mp3 "" "./output"
#
# Output:
#   Returns the task ID which can be used to query results
#

set -e

# API Configuration
API_SUBMIT_URL="https://openspeech.bytedance.com/api/v3/auc/bigmodel/submit"
API_RESOURCE_ID="volc.bigasr.auc"

# Check environment variables
if [ -z "$VOLCENGINE_API_APP_KEY" ] || [ -z "$VOLCENGINE_API_ACCESS_KEY" ]; then
    echo "❌ Error: Environment variables not set"
    echo ""
    echo "Please set the following environment variables:"
    echo "  export VOLCENGINE_API_APP_KEY='your-app-key'"
    echo "  export VOLCENGINE_API_ACCESS_KEY='your-access-key'"
    echo ""
    echo "Get your keys from: https://console.volcengine.com/openspeech"
    exit 1
fi

# Parse arguments
AUDIO_URL="$1"
FORMAT="${2:-mp3}"
LANGUAGE="${3:-}"
OUTPUT_DIR="${4:-./assets}"

# Validate arguments
if [ -z "$AUDIO_URL" ]; then
    echo "❌ Error: Audio URL is required"
    echo ""
    echo "Usage: $0 <audio_url> [format] [language] [output_dir]"
    echo ""
    echo "Arguments:"
    echo "  audio_url  : URL of the audio file (required)"
    echo "  format     : Audio format - mp3, wav, ogg, raw (default: mp3)"
    echo "  language   : Language code (optional)"
    echo "  output_dir : Output directory for results (default: ./assets)"
    echo ""
    echo "Examples:"
    echo "  $0 \"https://example.com/audio.mp3\""
    echo "  $0 \"https://example.com/audio.wav\" wav"
    echo "  $0 \"https://example.com/audio.mp3\" mp3 \"en-US\""
    echo "  $0 \"https://example.com/audio.mp3\" mp3 \"\" \"./output\""
    exit 1
fi

# Validate format
if [[ ! "$FORMAT" =~ ^(mp3|wav|ogg|raw)$ ]]; then
    echo "❌ Error: Invalid format '$FORMAT'"
    echo "Supported formats: mp3, wav, ogg, raw"
    exit 1
fi

# Function to upload local file to tmpfiles.org
upload_local_file() {
    local file_path="$1"
    local max_size=104857600  # 100MB in bytes

    # Check if file exists
    if [ ! -f "$file_path" ]; then
        echo "❌ Error: File not found: $file_path"
        return 1
    fi

    # Check file size
    local file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null)
    if [ "$file_size" -gt "$max_size" ]; then
        echo "❌ Error: File too large (max 100MB)"
        echo "File size: $((file_size / 1048576))MB"
        return 1
    fi

    echo "📤 Uploading local file to tmpfiles.org..." >&2
    echo "File: $file_path" >&2
    echo "Size: $((file_size / 1024 / 1024))MB" >&2

    # Upload to tmpfiles.org
    local upload_response=$(curl -s -F "file=@$file_path" https://tmpfiles.org/api/v1/upload)

    # Check if upload was successful
    if ! echo "$upload_response" | grep -q '"status":"success"'; then
        echo "❌ Error: Failed to upload file"
        echo "Response: $upload_response"
        return 1
    fi

    # Extract URL from response and convert to download URL
    local file_url=$(echo "$upload_response" | grep -o '"url":"[^"]*"' | cut -d'"' -f4 | head -1)

    if [ -z "$file_url" ]; then
        echo "❌ Error: Could not extract URL from response"
        echo "Response: $upload_response"
        return 1
    fi

    # Convert to download URL by inserting /dl/ after the domain
    local download_url=$(echo "$file_url" | sed 's|tmpfiles.org/|tmpfiles.org/dl/|')

    echo "✅ Upload successful!" >&2
    echo "Download URL: $download_url" >&2
    echo "$download_url"
    return 0
}

# Check if input is a local file or URL
if [[ "$AUDIO_URL" =~ ^https?:// ]]; then
    # It's a URL, use as is
    INPUT_URL="$AUDIO_URL"
    INPUT_TYPE="url"
else
    # It's a local file path, upload it
    echo "📁 Detected local file path"
    UPLOADED_URL=$(upload_local_file "$AUDIO_URL")
    if [ $? -ne 0 ]; then
        exit 1
    fi
    INPUT_URL="$UPLOADED_URL"
    INPUT_TYPE="file"
    echo ""
fi

# Generate unique request ID (UUID)
REQUEST_ID=$(uuidgen 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")

# Extract filename from URL (remove query parameters and extension)
AUDIO_FILENAME=$(basename "$AUDIO_URL" | sed 's/\?.*//' | sed 's/\.[^.]*$//')

# Function to submit task with specified resource ID
submit_task() {
    local resource_id="$1"
    local model_name="$2"

    # Build request JSON
    REQUEST_JSON=$(cat <<EOF
{
  "user": {
    "uid": "claude-code-user"
  },
  "audio": {
    "url": "$INPUT_URL",
    "format": "$FORMAT"
EOF
)

    # Add language if specified
    if [ -n "$LANGUAGE" ]; then
        REQUEST_JSON="$REQUEST_JSON,
    \"language\": \"$LANGUAGE\""
    fi

    REQUEST_JSON="$REQUEST_JSON
  },
  \"request\": {
    \"model_name\": \"bigmodel\",
    \"enable_itn\": true
  }
}"

    # Make API call
    RESPONSE=$(curl -s -X POST "$API_SUBMIT_URL" \
      -H "X-Api-App-Key: $VOLCENGINE_API_APP_KEY" \
      -H "X-Api-Access-Key: $VOLCENGINE_API_ACCESS_KEY" \
      -H "X-Api-Resource-Id: $resource_id" \
      -H "X-Api-Request-Id: $REQUEST_ID" \
      -H "X-Api-Sequence: -1" \
      -H "Content-Type: application/json" \
      -d "$REQUEST_JSON" \
      -i)

    # Extract status code from headers
    STATUS_CODE=$(echo "$RESPONSE" | grep -i "X-Api-Status-Code:" | awk '{print $2}' | tr -d '\r')
    MESSAGE=$(echo "$RESPONSE" | grep -i "X-Api-Message:" | cut -d' ' -f2- | tr -d '\r')
    LOG_ID=$(echo "$RESPONSE" | grep -i "X-Tt-Logid:" | awk '{print $2}' | tr -d '\r')

    # Return status code
    echo "$STATUS_CODE"
}

# Save metadata for query script
echo "$REQUEST_ID" > /tmp/volcengine_last_task_id
echo "$OUTPUT_DIR" > /tmp/volcengine_output_dir
echo "$AUDIO_FILENAME" > /tmp/volcengine_audio_filename

# Build request JSON
REQUEST_JSON=$(cat <<EOF
{
  "user": {
    "uid": "claude-code-user"
  },
  "audio": {
    "url": "$INPUT_URL",
    "format": "$FORMAT"
EOF
)

# Add language if specified
if [ -n "$LANGUAGE" ]; then
    REQUEST_JSON="$REQUEST_JSON,
    \"language\": \"$LANGUAGE\""
fi

REQUEST_JSON="$REQUEST_JSON
  },
  \"request\": {
    \"model_name\": \"bigmodel\",
    \"enable_itn\": true
  }
}"

# Submit request
echo "📤 Submitting ASR task..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$INPUT_TYPE" = "file" ]; then
    echo "Local File: $AUDIO_URL"
else
    echo "Audio URL: $AUDIO_URL"
fi
echo "Format: $FORMAT"
if [ -n "$LANGUAGE" ]; then
    echo "Language: $LANGUAGE"
fi
echo "Request ID: $REQUEST_ID"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Try Model 2.0 first (volc.seedasr.auc)
echo "🔄 Trying Model 2.0 (volc.seedasr.auc)..."
STATUS_CODE=$(submit_task "volc.seedasr.auc" "bigmodel")
MESSAGE=$(echo "$RESPONSE" | grep -i "X-Api-Message:" | cut -d' ' -f2- | tr -d '\r')
LOG_ID=$(echo "$RESPONSE" | grep -i "X-Tt-Logid:" | awk '{print $2}' | tr -d '\r')

# If Model 2.0 fails with resource not granted (45000030), fall back to Model 1.0
if [ "$STATUS_CODE" = "45000030" ]; then
    echo "⚠️  Model 2.0 not available, falling back to Model 1.0 (volc.bigasr.auc)..."
    STATUS_CODE=$(submit_task "volc.bigasr.auc" "bigmodel")
    MESSAGE=$(echo "$RESPONSE" | grep -i "X-Api-Message:" | cut -d' ' -f2- | tr -d '\r')
    LOG_ID=$(echo "$RESPONSE" | grep -i "X-Tt-Logid:" | awk '{print $2}' | tr -d '\r')
    API_RESOURCE_ID="volc.bigasr.auc"
    MODEL_VERSION="1.0"
else
    API_RESOURCE_ID="volc.seedasr.auc"
    MODEL_VERSION="2.0"
fi

# Save the actual resource ID used for query
echo "$API_RESOURCE_ID" > /tmp/volcengine_resource_id

# Check result
if [ "$STATUS_CODE" = "20000000" ]; then
    echo "✅ Task submitted successfully!"
    echo ""
    echo "Task ID: $REQUEST_ID"
    echo "Log ID: $LOG_ID"
    echo "Model Version: $MODEL_VERSION (Resource ID: $API_RESOURCE_ID)"
    echo "Output Directory: $OUTPUT_DIR"
    echo ""
    echo "Use this command to check status:"
    echo "  ./query_task.sh \"$REQUEST_ID\""
    exit 0
else
    echo "❌ Task submission failed!"
    echo ""
    echo "Status Code: $STATUS_CODE"
    echo "Message: $MESSAGE"
    echo "Log ID: $LOG_ID"
    echo ""
    case "$STATUS_CODE" in
        45000001)
            echo "💡 Possible causes:"
            echo "   - Missing required fields"
            echo "   - Invalid parameter values"
            echo "   - Duplicate request"
            ;;
        45000151)
            echo "💡 Possible causes:"
            echo "   - Audio format not supported"
            echo "   - Audio file corrupted"
            ;;
        55000031)
            echo "💡 Server busy, please try again later"
            ;;
    esac
    exit 1
fi
