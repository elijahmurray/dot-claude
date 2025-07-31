#!/bin/bash

# setup-as-submodule.sh
# Helper script to add dot-claude as a submodule to an existing project

set -e

echo "🔧 dot-claude Submodule Setup"
echo "============================"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository!"
    echo "Please run this from your project's root directory."
    exit 1
fi

# Check if .claude already exists
if [ -e ".claude" ]; then
    echo "❌ Error: .claude already exists!"
    echo ""
    echo "If it's already a submodule, check with:"
    echo "  git submodule status"
    echo ""
    echo "If it's a regular directory, you can:"
    echo "  1. Back it up: mv .claude .claude.backup"
    echo "  2. Remove it: rm -rf .claude"
    echo "  3. Run this script again"
    exit 1
fi

# Get the repository URL
DEFAULT_REPO="https://github.com/elijahmurray/dot-claude.git"
echo ""
echo "📦 Repository URL (press Enter for default):"
echo "Default: $DEFAULT_REPO"
read -p "URL: " REPO_URL
REPO_URL=${REPO_URL:-$DEFAULT_REPO}

# Add the submodule
echo ""
echo "📥 Adding dot-claude as a submodule..."
git submodule add "$REPO_URL" .claude

# Initialize and update the submodule
echo "🔄 Initializing submodule..."
git submodule init
git submodule update

# Copy the example settings
echo ""
echo "📄 Setting up configuration..."
if [ -f ".claude/settings.local.json.example" ]; then
    cp .claude/settings.local.json.example .claude/settings.local.json
    echo "✅ Created .claude/settings.local.json from example"
    echo "   Please edit this file to customize your settings"
else
    echo "⚠️  No settings.local.json.example found"
fi

# Create .gitignore entries
echo ""
echo "📝 Updating .gitignore..."
if ! grep -q "^\.claude/settings\.local\.json$" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# Claude local settings" >> .gitignore
    echo ".claude/settings.local.json" >> .gitignore
    echo "✅ Added .claude/settings.local.json to .gitignore"
else
    echo "✅ .gitignore already contains settings.local.json entry"
fi

# Show next steps
echo ""
echo "✨ Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Edit .claude/settings.local.json with your preferences"
echo "2. Commit the changes:"
echo "   git add .gitmodules .claude .gitignore"
echo "   git commit -m \"Add .claude as submodule\""
echo ""
echo "To update .claude in the future:"
echo "   /cmd-claude-update"
echo ""
echo "For team members cloning this project:"
echo "   git clone --recursive <your-repo-url>"
echo "   # or if already cloned:"
echo "   git submodule init && git submodule update"