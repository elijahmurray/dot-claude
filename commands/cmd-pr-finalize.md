# pr-finalize.md

Run final checks before merging a pull request.

## Variables
- BRANCH_NAME: The name of the feature branch (optional, will detect current if not provided)

## Instructions

This command runs final checks and tests BEFORE merging the PR.

### 1. Determine Current Branch
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
        # We're in main repo
        FEATURE_BRANCH="$CURRENT_BRANCH"
        echo "📍 On branch: $FEATURE_BRANCH"
    fi
else
    FEATURE_BRANCH="$BRANCH_NAME"
fi

# Get default branch name
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Ensure we're not on default branch
if [ "$FEATURE_BRANCH" == "$DEFAULT_BRANCH" ]; then
    echo "❌ Cannot prepare $DEFAULT_BRANCH branch for merge"
    exit 1
fi
```

### 2. Check PR Status
```bash
# Check if PR exists (requires gh CLI)
if command -v gh &> /dev/null; then
    PR_INFO=$(gh pr view "$FEATURE_BRANCH" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "✅ Found PR for branch: $FEATURE_BRANCH"
        echo "$PR_INFO" | grep -E "^title:|^state:"
    else
        echo "⚠️  No PR found for branch: $FEATURE_BRANCH"
        echo "Create one with: gh pr create"
    fi
fi
```

### 3. Run Final Checks
```bash
# Run tests
echo "🧪 Running tests..."
# Common test commands - use what applies to your project
npm test 2>/dev/null || yarn test 2>/dev/null || pytest 2>/dev/null || go test ./... 2>/dev/null || cargo test 2>/dev/null || make test 2>/dev/null || echo "⚠️  No test command found - please run tests manually"

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  You have uncommitted changes. Please commit them before merging."
    git status --short
fi

# Push latest changes
echo "📤 Pushing latest changes..."
git push origin "$FEATURE_BRANCH"
```

### 4. Summary
```bash
echo ""
echo "📋 PR Final Checklist:"
echo "✅ Tests passing"
echo "✅ Code linted and formatted"
echo "✅ All changes committed and pushed"
echo "✅ PR is up to date with $DEFAULT_BRANCH"
echo ""
echo "🎯 Next steps:"
echo "1. Review the PR one final time"
echo "2. Merge when approved"
echo "3. Run /cmd-issue-complete after merge"
```

## Purpose
This command runs final checks before merging by ensuring:
- All tests are passing
- Code is properly formatted and linted
- Latest changes are pushed
- The branch is ready to merge

## Usage Examples
```bash
# From within a worktree
/cmd-pr-finalize

# From main repo with branch name
/cmd-pr-finalize feature/add-authentication

# Before merging a PR
/cmd-pr-finalize feature/new-feature
```