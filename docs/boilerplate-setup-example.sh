#!/bin/bash

# Example setup script for your boilerplate project
# This shows how to integrate dot-claude as a submodule

echo "🚀 Setting up new project from boilerplate..."

# ... other setup steps ...

# Add dot-claude as a submodule instead of cloning
echo "📦 Adding .claude configuration..."
git submodule add https://github.com/elijahmurray/dot-claude.git .claude
git submodule init
git submodule update

# Create settings.local.json from example
if [ -f ".claude/settings.local.json.example" ]; then
    cp .claude/settings.local.json.example .claude/settings.local.json
    echo "✅ Created .claude/settings.local.json"
fi

# Make sure settings.local.json is gitignored
if ! grep -q "^\.claude/settings\.local\.json$" .gitignore 2>/dev/null; then
    echo ".claude/settings.local.json" >> .gitignore
fi

# Commit the submodule addition
git add .gitmodules .claude .gitignore
git commit -m "Add .claude configuration as submodule"

echo "✅ Project setup complete!"
echo ""
echo "📝 Next steps for team members:"
echo "   When cloning this project, use:"
echo "   git clone --recursive <repo-url>"
echo ""
echo "📝 To update .claude in the future:"
echo "   /cmd-claude-update"