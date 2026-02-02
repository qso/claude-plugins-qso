#!/bin/bash
#
# Volcengine ASR - Query Task Script
#
# Usage:
#   ./query_task.sh <task_id>
#
# Arguments:
#   task_id  : The task ID returned from submit_task.sh
#
# Examples:
#   ./query_task.sh "67ee89ba-7050-4c04-a3d7-ac61a63499b3"
#
# Output:
#   Returns the transcription status and results (if completed)
#

set -e

# API Configuration
API_QUERY_URL="https://openspeech.bytedance.com/api/v3/auc/bigmodel/query"

# Check environment variables
if [ -z "$VOLCENGINE_API_APP_KEY" ] || [ -z "$VOLCENGINE_API_ACCESS_KEY" ]; then
    echo "❌ Error: Environment variables not set"
    echo ""
    echo "Please set the following environment variables:"
    echo "  export VOLCENGINE_API_APP_KEY='your-app-key'"
    echo "  export VOLCENGINE_API_ACCESS_KEY='your-access-key'"
    exit 1
fi

# Parse arguments
TASK_ID="$1"

# Read metadata from last submission (if available)
if [ -f "/tmp/volcengine_resource_id" ]; then
    API_RESOURCE_ID=$(cat /tmp/volcengine_resource_id)
else
    API_RESOURCE_ID="volc.bigasr.auc"
fi

if [ -f "/tmp/volcengine_output_dir" ]; then
    OUTPUT_DIR=$(cat /tmp/volcengine_output_dir)
else
    OUTPUT_DIR="./assets"
fi

if [ -f "/tmp/volcengine_audio_filename" ]; then
    AUDIO_FILENAME=$(cat /tmp/volcengine_audio_filename)
else
    AUDIO_FILENAME="transcription"
fi

# Validate arguments
if [ -z "$TASK_ID" ]; then
    # Try to read from last submission
    if [ -f "/tmp/volcengine_last_task_id" ]; then
        TASK_ID=$(cat /tmp/volcengine_last_task_id)
        echo "Using last submitted task ID: $TASK_ID"
        echo ""
    else
        echo "❌ Error: Task ID is required"
        echo ""
        echo "Usage: $0 <task_id>"
        echo ""
        echo "Arguments:"
        echo "  task_id  : The task ID returned from submit_task.sh"
        echo ""
        echo "Examples:"
        echo "  $0 \"67ee89ba-7050-4c04-a3d7-ac61a63499b3\""
        echo ""
        echo "Tip: If you just submitted a task, the ID is saved in /tmp/volcengine_last_task_id"
        exit 1
    fi
fi

# Query status
echo "🔍 Querying task status..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Task ID: $TASK_ID"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Make API call
RESPONSE=$(curl -s -X POST "$API_QUERY_URL" \
  -H "X-Api-App-Key: $VOLCENGINE_API_APP_KEY" \
  -H "X-Api-Access-Key: $VOLCENGINE_API_ACCESS_KEY" \
  -H "X-Api-Resource-Id: $API_RESOURCE_ID" \
  -H "X-Api-Request-Id: $TASK_ID" \
  -H "Content-Type: application/json" \
  -d "{}" \
  -i)

# Extract status code from headers
STATUS_CODE=$(echo "$RESPONSE" | grep -i "X-Api-Status-Code:" | awk '{print $2}' | tr -d '\r')
MESSAGE=$(echo "$RESPONSE" | grep -i "X-Api-Message:" | cut -d' ' -f2- | tr -d '\r')
LOG_ID=$(echo "$RESPONSE" | grep -i "X-Tt-Logid:" | awk '{print $2}' | tr -d '\r')

# Extract response body (after the headers)
RESPONSE_BODY=$(echo "$RESPONSE" | sed -n '/^{/,$p')

# Check status
case "$STATUS_CODE" in
    20000000)
        # Success - transcription complete
        echo "✅ Transcription complete!"
        echo ""
        echo "Log ID: $LOG_ID"
        echo ""

        # Create output directory
        mkdir -p "$OUTPUT_DIR"

        # Generate output filename
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        OUTPUT_BASE="${AUDIO_FILENAME}_${TIMESTAMP}"
        JSON_FILE="${OUTPUT_DIR}/${OUTPUT_BASE}.json"
        TXT_FILE="${OUTPUT_DIR}/${OUTPUT_BASE}.txt"

        # Parse and display results
        if command -v jq &> /dev/null; then
            # Use jq for pretty printing
            TEXT=$(echo "$RESPONSE_BODY" | jq -r '.result.text // empty')
            DURATION=$(echo "$RESPONSE_BODY" | jq -r '.audio_info.duration // empty' 2>/dev/null || echo "N/A")

            if [ -n "$TEXT" ]; then
                echo "📝 Transcription:"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "$TEXT"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""

                # Display utterances if available
                UTTERANCES=$(echo "$RESPONSE_BODY" | jq -r '.result.utterances // empty' 2>/dev/null)
                if [ "$UTTERANCES" != "null" ] && [ -n "$UTTERANCES" ]; then
                    echo "📊 Segments with timestamps:"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "$RESPONSE_BODY" | jq -r '.result.utterances[] |
                        "[\(.start_time / 1000 | strftime("%H:%M:%S")) - \(.end_time / 1000 | strftime("%H:%M:%S"))] \(.text // "")"' 2>/dev/null || \
                    echo "$RESPONSE_BODY" | jq -r '.result.utterances[] |
                        "[\(.start_time / 1000)s - \(.end_time / 1000)s] \(.text // "")"'
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo ""
                fi

                # Save JSON and TXT files
                echo "$RESPONSE_BODY" > "$JSON_FILE"
                echo "$TEXT" > "$TXT_FILE"

                echo "💾 Results saved to:"
                echo "   📄 JSON: $JSON_FILE"
                echo "   📝 TXT:  $TXT_FILE"
            else
                echo "⚠️  No transcription text found"
                echo ""
                echo "Full response:"
                echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"

                # Still save JSON response
                echo "$RESPONSE_BODY" > "$JSON_FILE"
                echo "💾 JSON response saved to: $JSON_FILE"
            fi
        else
            # jq not available, try to extract text with basic tools
            TEXT=$(echo "$RESPONSE_BODY" | grep -o '"text"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"text"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')

            echo "📝 Full Response:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "$RESPONSE_BODY"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""

            # Save files
            echo "$RESPONSE_BODY" > "$JSON_FILE"
            if [ -n "$TEXT" ]; then
                echo "$TEXT" > "$TXT_FILE"
                echo "💾 Results saved to:"
                echo "   📄 JSON: $JSON_FILE"
                echo "   📝 TXT:  $TXT_FILE"
            else
                echo "💾 JSON response saved to: $JSON_FILE"
            fi
            echo ""
            echo "💡 Tip: Install 'jq' for better formatted output"
        fi

        exit 0
        ;;

    20000001)
        # Processing
        echo "⏳ Task is still processing..."
        echo ""
        echo "Log ID: $LOG_ID"
        echo ""
        echo "Please wait a moment and query again:"
        echo "  ./query_task.sh \"$TASK_ID\""
        echo ""
        echo "Or use the watch command for continuous polling:"
        echo "  watch -n 3 './query_task.sh \"$TASK_ID\"'"
        exit 1
        ;;

    20000002)
        # Queued
        echo "📋 Task is in the queue..."
        echo ""
        echo "Log ID: $LOG_ID"
        echo ""
        echo "Please wait and query again in a few seconds:"
        echo "  ./query_task.sh \"$TASK_ID\""
        exit 1
        ;;

    20000003)
        # Silent audio
        echo "⚠️  Silent audio detected"
        echo ""
        echo "Log ID: $LOG_ID"
        echo "Message: $MESSAGE"
        echo ""
        echo "The audio appears to be silent. Please try with a different audio file."
        exit 1
        ;;

    45000001)
        # Invalid parameters
        echo "❌ Invalid request parameters"
        echo ""
        echo "Log ID: $LOG_ID"
        echo "Message: $MESSAGE"
        exit 1
        ;;

    45000002)
        # Empty audio
        echo "❌ Empty audio file"
        echo ""
        echo "Log ID: $LOG_ID"
        echo "Message: $MESSAGE"
        exit 1
        ;;

    *)
        # Other errors
        echo "❌ Unknown status"
        echo ""
        echo "Status Code: $STATUS_CODE"
        echo "Message: $MESSAGE"
        echo "Log ID: $LOG_ID"
        echo ""
        echo "Full response:"
        echo "$RESPONSE_BODY"
        exit 1
        ;;
esac
