# issue-complete.md

Clean up after merging an issue's PR (worktree removal, branch deletion).

## Variables
- BRANCH_NAME: The name of the feature branch (optional, will detect current if not provided)

## Instructions

This command handles post-merge cleanup:

### 1. Verify Merge Status
```bash
# Check current location
CURRENT_DIR=$(pwd)
CURRENT_BRANCH=$(git branch --show-current)

# Determine the feature branch
if [ -z "$BRANCH_NAME" ]; then
    if [[ "$CURRENT_DIR" == *"/trees/"* ]]; then
        # We're in a worktree
        FEATURE_BRANCH="$CURRENT_BRANCH"
        echo "📍 In worktree for branch: $FEATURE_BRANCH"
    else
        # We're in main repo, need branch name
        echo "❌ Please provide the feature branch name"
        exit 1
    fi
else
    FEATURE_BRANCH="$BRANCH_NAME"
fi

# Verify the branch has been merged
cd $(git rev-parse --show-toplevel)  # Go to main repo
git checkout main
git pull origin main 2>/dev/null || echo "No remote configured"

if ! git branch --merged main | grep -q "$FEATURE_BRANCH"; then
    echo "❌ Branch $FEATURE_BRANCH has not been merged into main yet"
    echo "Please merge the PR/branch first before completing the issue"
    exit 1
fi

echo "✅ Branch $FEATURE_BRANCH has been merged into main"
```

### 2. Clean Up Worktree (if exists)
```bash
# Check if worktree exists
WORKTREE_PATH=$(git worktree list | grep "$FEATURE_BRANCH" | awk '{print $1}')

if [ -n "$WORKTREE_PATH" ]; then
    echo "🧹 Removing worktree at: $WORKTREE_PATH"
    git worktree remove "$WORKTREE_PATH" --force
    echo "✅ Worktree removed"
fi
```

### 3. Delete Feature Branch
```bash
# Delete the local branch
git branch -d "$FEATURE_BRANCH" 2>/dev/null || git branch -D "$FEATURE_BRANCH"
echo "✅ Deleted local branch: $FEATURE_BRANCH"

# Delete remote branch if it exists
git push origin --delete "$FEATURE_BRANCH" 2>/dev/null || echo "No remote branch to delete"
```

### 4. Final Summary
```bash
echo ""
echo "🎉 Issue cleanup completed!"
echo ""
echo "✅ Worktree removed (if existed)"
echo "✅ Feature branch deleted"
echo ""
echo "📍 You are now on: $(git branch --show-current)"
echo "🚀 Ready for the next issue!"
echo ""
echo "💡 Claude session can be safely closed - all work is complete!"
```

## Next Steps

After completing an issue, you have several options:

1. **Start a New Issue**:
   - Find or create a new issue to work on
   - Run `/cmd-issue-start` with the new issue details

2. **Review Other Work**:
   - Check other PRs that need review: `/cmd-pr-review`
   - Look at existing worktrees: `git worktree list`

3. **Update Project Status**:
   - Push changes if using remote: `git push origin main`
   - Update project board or issue tracker
   - Close the completed issue

4. **Take a Break**:
   - You've completed a full development cycle!
   - All artifacts are properly documented and cleaned up
   - The codebase is ready for the next feature

## Purpose
This command cleans up after a merged issue:
- Ensures the feature is properly merged
- Removes the worktree (if it exists)
- Deletes local and remote feature branches
- Provides a clean slate for the next issue

## Usage Examples
```bash
# From within a worktree
/cmd-issue-complete

# From main repo with branch name
/cmd-issue-complete feature/add-authentication

# After merging a PR
/cmd-issue-complete feature/google-calendar-crud
```
