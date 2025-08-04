#!/bin/bash

# claude-update.sh - Automated .claude submodule update
# Usage: claude-update.sh [--force]

set -e

# Parse arguments
FORCE_UPDATE=false
if [ "$1" == "--force" ]; then
    FORCE_UPDATE=true
fi

echo "🔍 Checking .claude status..."

# Check if .claude is a submodule
if [ -f ".gitmodules" ] && grep -q ".claude" .gitmodules; then
    echo "✅ .claude is configured as a submodule"
    
    # Show current status
    cd .claude
    CURRENT_COMMIT=$(git rev-parse --short HEAD)
    CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
    echo "📍 Current commit: $CURRENT_COMMIT"
    echo "🌿 Current branch: $CURRENT_BRANCH"
    
    # Check for local changes
    if [ -n "$(git status --porcelain)" ]; then
        echo "⚠️  Warning: You have uncommitted changes in .claude"
        git status --short
        echo ""
        echo "Please commit or stash these changes before updating."
        exit 1
    fi
else
    echo "❌ .claude is not a submodule!"
    echo ""
    echo "To set it up as a submodule, run:"
    echo "  bash .claude/scripts/setup-as-submodule.sh"
    exit 1
fi

# Check if we're behind
git fetch origin
BEHIND=$(git rev-list --count HEAD..origin/main)

if [ "$BEHIND" -eq 0 ]; then
    echo "✅ Already up to date!"
    cd ..
    exit 0
else
    echo "📊 You are $BEHIND commits behind origin/main"
fi

# Update without prompting (or with force flag)
if [ "$FORCE_UPDATE" = true ]; then
    echo "🔄 Force updating to latest version..."
else
    echo "🔄 Updating to latest version..."
fi

# Checkout main and pull
echo "📦 Updating .claude..."
git checkout main
git pull origin main

# Show what changed
echo ""
echo "📝 Changes:"
git log --oneline $CURRENT_COMMIT..HEAD

# Return to parent directory
cd ..

# Stage the submodule update
git add .claude

echo ""
echo "✅ .claude updated successfully!"
echo ""
echo "To complete the update:"
echo "  git commit -m \"Update .claude to latest version\""
echo ""
echo "📖 Check DEV_EXPERIENCE_CHANGELOG.md for details on what's new!"