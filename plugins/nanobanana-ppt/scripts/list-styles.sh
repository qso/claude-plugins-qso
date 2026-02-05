#!/bin/bash
# List all available PPT styles with metadata
# Output format: AI-readable structured text

STYLES_DIR="${CLAUDE_PLUGIN_ROOT}/styles"

if [ ! -d "$STYLES_DIR" ]; then
  echo "ERROR: Styles directory not found: $STYLES_DIR"
  exit 1
fi

echo "=== Available PPT Styles ==="
echo ""

for file in "$STYLES_DIR"/*.md; do
  if [ -f "$file" ]; then
    # Extract metadata from HTML comments
    # Format in file: "style_id: value" (on same line)
    style_id=$(grep '^style_id:' "$file" | cut -d':' -f2- | xargs)
    style_name=$(grep '^style_name:' "$file" | cut -d':' -f2- | xargs)
    tags=$(grep '^tags:' "$file" | cut -d':' -f2- | xargs)
    use_cases=$(grep '^use_cases:' "$file" | cut -d':' -f2- | xargs)

    # Output in AI-friendly format
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Style ID: $style_id"
    echo "Name: $style_name"
    echo "Tags: $tags"
    echo "Use Cases: $use_cases"
    echo ""
  fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total: $(ls -1 "$STYLES_DIR"/*.md 2>/dev/null | wc -l | xargs) styles"
