#\!/bin/bash

# Claude Code Agent Completion Notification Script
# This script sends desktop notifications when Claude Code agents complete their tasks
#
# Usage: notify-agent-complete.sh <type> [description] [tab_name] [work_summary]
#
# Parameters:
#   type         - Notification type: "main", "task", "notification", "attention"
#   description  - Optional: Description of the task/work completed
#   tab_name     - Optional: Name of the Warp tab that triggered the notification
#   work_summary - Optional: Summary of work completed (for "main" type)
#
# Examples:
#   ./notify-agent-complete.sh notification "Code review needed" "evie-backend"
#   ./notify-agent-complete.sh task "Created 3 GitHub issues for MCP testing" "testing-tab"
#   ./notify-agent-complete.sh main "All MCP servers tested successfully" "project-work" "Fixed 5 bugs and added comprehensive test coverage"
#   ./notify-agent-complete.sh attention "Build failed - check logs" "deploy-tab"

# Prevent infinite loops by checking if we're already running
LOCKFILE="/tmp/claude_notify.lock"
if [ -f "$LOCKFILE" ]; then
    echo "Notification script already running, skipping..." >&2
    exit 0
fi

# Create lockfile
touch "$LOCKFILE"

# Clean up lockfile on exit
trap 'rm -f "$LOCKFILE"' EXIT

# Get the notification type from the first argument
NOTIFICATION_TYPE="$1"

# Get additional details from remaining arguments
TASK_DESCRIPTION="$2"
TAB_NAME="$3"
WORK_SUMMARY="$4"

# No timestamp needed - notifications are immediate

# Function to send notification using terminal-notifier (more reliable)
send_notification() {
    local title="$1"
    local message="$2"
    local subtitle="$3"
    local sound="$4"
    
    # Try terminal-notifier first (more reliable)
    if command -v terminal-notifier >/dev/null 2>&1; then
        terminal-notifier -title "$title" -message "$message" -subtitle "$subtitle" -sound "$sound" >/dev/null 2>&1
    else
        # Fallback to osascript
        osascript -e "display notification \"$message\" with title \"$title\" subtitle \"$subtitle\" sound name \"$sound\"" 2>/dev/null
        
        # If osascript fails, try dialog as fallback
        if [ $? -ne 0 ]; then
            osascript -e "display dialog \"$title\n\n$message\n$subtitle\" buttons {\"OK\"} default button 1" 2>/dev/null
        fi
    fi
    
    # Play system sound as audio feedback
    afplay /System/Library/Sounds/${sound}.aiff 2>/dev/null || afplay /System/Library/Sounds/Glass.aiff 2>/dev/null
}

# Determine notification content based on type
case "$NOTIFICATION_TYPE" in
    "main")
        # Main agent completion - use work summary or description
        TITLE="🤖 Claude Code Complete"
        if [ -n "$WORK_SUMMARY" ]; then
            MESSAGE="$WORK_SUMMARY"
        elif [ -n "$TASK_DESCRIPTION" ]; then
            MESSAGE="$TASK_DESCRIPTION"
        else
            MESSAGE="Main agent has finished executing"
        fi
        SUBTITLE="$TAB_NAME"
        send_notification "$TITLE" "$MESSAGE" "$SUBTITLE" "Glass"
        ;;
    
    "task")
        # Subagent/task completion - use description for dynamic content
        TITLE="✅ Task Complete"
        if [ -n "$TASK_DESCRIPTION" ]; then
            MESSAGE="$TASK_DESCRIPTION"
        else
            MESSAGE="Subagent task has finished"
        fi
        SUBTITLE="$TAB_NAME"
        send_notification "$TITLE" "$MESSAGE" "$SUBTITLE" "Pop"
        ;;
    
    "notification")
        # Claude needs user input - use description for specific request
        TITLE="⚠️ Claude Needs Input"
        if [ -n "$TASK_DESCRIPTION" ]; then
            MESSAGE="$TASK_DESCRIPTION"
        else
            MESSAGE="Your attention is required"
        fi
        SUBTITLE="$TAB_NAME"
        send_notification "$TITLE" "$MESSAGE" "$SUBTITLE" "Ping"
        ;;
    
    "attention")
        # Tab needs attention - use description for specific issue
        TITLE="🔔 Tab Needs Attention"
        if [ -n "$TASK_DESCRIPTION" ]; then
            MESSAGE="$TASK_DESCRIPTION"
        else
            MESSAGE="A Warp tab requires your attention"
        fi
        SUBTITLE="$TAB_NAME"
        send_notification "$TITLE" "$MESSAGE" "$SUBTITLE" "Ping"
        ;;
    
    *)
        # Default notification - fully dynamic based on description
        TITLE="🔔 Claude Code"
        if [ -n "$TASK_DESCRIPTION" ]; then
            MESSAGE="$TASK_DESCRIPTION"
        else
            MESSAGE="Event triggered"
        fi
        SUBTITLE="$TAB_NAME"
        send_notification "$TITLE" "$MESSAGE" "$SUBTITLE" "Pop"
        ;;
esac

# Exit successfully
exit 0
EOF < /dev/null