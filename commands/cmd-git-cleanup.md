# git-cleanup.md

Clean up merged branches and unused worktrees from the repository.

## Instructions

This command helps maintain a clean git environment by removing:
- Worktrees for branches that have been merged
- Local branches that have been merged into main
- Remote tracking branches that no longer exist

### 1. Find and Clean Merged Worktrees
```bash
echo "🔍 Checking for worktrees to clean up..."

# List all worktrees
WORKTREES=$(git worktree list --porcelain | grep "worktree" | cut -d' ' -f2)

# Check each worktree
for WORKTREE in $WORKTREES; do
    if [[ "$WORKTREE" == *"/trees/"* ]]; then
        # Get branch name from worktree
        BRANCH=$(cd "$WORKTREE" 2>/dev/null && git branch --show-current)
        
        # Check if branch is merged
        if git branch --merged main | grep -q "$BRANCH" 2>/dev/null; then
            echo "🧹 Removing merged worktree: $WORKTREE (branch: $BRANCH)"
            git worktree remove "$WORKTREE" --force
        fi
    fi
done
```

### 2. Clean Merged Local Branches
```bash
echo "🔍 Checking for merged branches to clean up..."

# Get all merged branches except main
MERGED_BRANCHES=$(git branch --merged main | grep -v "main" | grep -v "*")

if [ -n "$MERGED_BRANCHES" ]; then
    echo "Found merged branches:"
    echo "$MERGED_BRANCHES"
    
    # Delete each merged branch
    for BRANCH in $MERGED_BRANCHES; do
        BRANCH=$(echo "$BRANCH" | xargs)  # Trim whitespace
        echo "🗑️  Deleting branch: $BRANCH"
        git branch -d "$BRANCH"
    done
else
    echo "✅ No merged branches to clean up"
fi
```

### 3. Prune Remote Tracking Branches
```bash
echo "🔍 Pruning remote tracking branches..."

# Prune remote branches
git remote prune origin
```

### 4. Summary Report
```bash
echo ""
echo "🎉 Git cleanup completed!"
echo ""
echo "✅ Removed merged worktrees"
echo "✅ Deleted merged local branches"
echo "✅ Pruned remote tracking branches"
echo ""
echo "📊 Current status:"
echo "Remaining worktrees:"
git worktree list
echo ""
echo "Remaining branches:"
git branch -a
```

## Purpose
This command helps maintain a clean development environment by:
- Removing worktrees for completed features
- Deleting branches that have been merged
- Keeping the repository organized and efficient

## Usage Examples
```bash
# Run cleanup
/cmd-git-cleanup

# Run after completing multiple features
/cmd-git-cleanup
```
