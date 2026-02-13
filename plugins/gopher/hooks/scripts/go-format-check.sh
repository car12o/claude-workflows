#!/usr/bin/env bash
# Post-edit hook: advisory format check for Go files.
# Non-blocking — reports issues as a system message but never fails the hook.

set -euo pipefail

# Read the tool result from stdin to extract the file path
input=$(cat)

# Extract file path from the tool result JSON
file_path=$(echo "$input" | grep -oP '"filePath"\s*:\s*"\K[^"]+' 2>/dev/null || true)

# If no filePath found, try file_path key
if [ -z "$file_path" ]; then
    file_path=$(echo "$input" | grep -oP '"file_path"\s*:\s*"\K[^"]+' 2>/dev/null || true)
fi

# Only check .go files
if [ -z "$file_path" ] || [[ "$file_path" != *.go ]]; then
    exit 0
fi

# Check if file exists
if [ ! -f "$file_path" ]; then
    exit 0
fi

# Check if gofmt is available
if ! command -v gofmt &>/dev/null; then
    exit 0
fi

# Run gofmt to detect formatting issues
unformatted=$(gofmt -l "$file_path" 2>/dev/null || true)

if [ -n "$unformatted" ]; then
    echo '{"systemMessage": "Go format advisory: '"$file_path"' has formatting issues. Run `gofmt -s -w '"$file_path"'` or let the quality gates handle it."}'
fi
