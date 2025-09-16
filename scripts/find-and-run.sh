#!/bin/bash

# find-and-run.sh
# Universal script wrapper that finds and executes .claude scripts from any directory
# Usage: find-and-run.sh <script-name> [arguments...]
#
# This script searches up the directory tree to find the project root (containing .git)
# then executes the requested script from .claude/scripts/

set -e

# Get the script name and shift to get remaining arguments
SCRIPT_NAME="$1"
shift

# Function to find project root (directory containing .git)
find_project_root() {
    local current_dir="$(pwd)"
    while [[ "$current_dir" != "/" ]]; do
        if [[ -d "$current_dir/.git" ]] || [[ -f "$current_dir/.git" ]]; then
            echo "$current_dir"
            return
        fi
        current_dir="$(dirname "$current_dir")"
    done
    # If no git root found, return empty
    echo ""
}

# Find project root
PROJECT_ROOT=$(find_project_root)

if [ -z "$PROJECT_ROOT" ]; then
    echo "❌ Error: Not in a git repository" >&2
    exit 1
fi

# Construct full script path - try both .claude/scripts and scripts directories
SCRIPT_PATH="$PROJECT_ROOT/.claude/scripts/$SCRIPT_NAME"

# If not found in .claude/scripts, try scripts directory (for dot-claude repo itself)
if [ ! -f "$SCRIPT_PATH" ]; then
    SCRIPT_PATH="$PROJECT_ROOT/scripts/$SCRIPT_NAME"
fi

# Check if script exists
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ Error: Script not found: $SCRIPT_NAME" >&2
    echo "Searched in:" >&2
    echo "  - $PROJECT_ROOT/.claude/scripts/" >&2
    echo "  - $PROJECT_ROOT/scripts/" >&2
    exit 1
fi

# Make sure script is executable
chmod +x "$SCRIPT_PATH" 2>/dev/null || true

# Execute the script with all remaining arguments
exec "$SCRIPT_PATH" "$@"