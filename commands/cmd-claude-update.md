# cmd-claude-update.md

Update the .claude submodule to the latest version from the main repository.

## Instructions

This command helps you update your .claude directory when it's included as a git submodule.

### 1. Check Current Status

First, let's check if .claude is a submodule and what version you're on:

```bash
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
```

### 2. Fetch Latest Changes

```bash
echo ""
echo "📥 Fetching latest changes..."
git fetch origin

# Show what's new
echo ""
echo "📋 Recent updates:"
git log --oneline HEAD..origin/main | head -10

# Count commits behind
BEHIND=$(git rev-list --count HEAD..origin/main)
if [ "$BEHIND" -eq 0 ]; then
    echo ""
    echo "✅ Already up to date!"
    cd ..
    exit 0
else
    echo ""
    echo "📊 You are $BEHIND commits behind origin/main"
fi
```

### 3. Update to Latest

```bash
echo ""
read -p "🔄 Update to latest version? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
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
else
    echo "❌ Update cancelled"
    cd ..
fi
```

### 4. Alternative: Update to Specific Version

If you need a specific version instead of latest:

```bash
# To update to a specific tag or commit:
cd .claude
git fetch --tags
echo ""
echo "Available tags:"
git tag -l | tail -10

echo ""
echo "To switch to a specific version:"
echo "  cd .claude"
echo "  git checkout v1.2.3  # or specific commit"
echo "  cd .."
echo "  git add .claude"
echo "  git commit -m \"Pin .claude to version v1.2.3\""
```

## Troubleshooting

### If you see "modified content" warnings:

This usually means you have local changes in .claude. Either:
1. Commit them to a local branch
2. Stash them: `cd .claude && git stash`
3. Discard them: `cd .claude && git checkout .`

### If the update fails:

```bash
# Reset to a clean state
cd .claude
git reset --hard HEAD
git checkout main
git pull origin main
```

## Purpose

This command simplifies the process of keeping your .claude commands and workflows up to date with the latest improvements from the community.