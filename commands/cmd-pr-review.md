# pr-review.md

Review and implement feedback on a pull request.

## Variables
- PR_NUMBER: The PR number or URL to review
- BRANCH_NAME: The branch name (optional, will be extracted from PR)

## Instructions

You are a senior engineer responsible for reviewing PRs, implementing feedback, and ensuring quality before merge.

### 1. Fetch PR Information
```bash
# Extract PR number from URL if provided
if [[ "$PR_NUMBER" == *"github.com"* ]]; then
    PR_NUMBER=$(echo "$PR_NUMBER" | grep -oE '[0-9]+$')
fi

# Get PR details
echo "🔍 Fetching PR #$PR_NUMBER details..."
gh pr view "$PR_NUMBER" --json title,branch,state,author,body,comments
```

### 2. Check Out PR Code
```bash
# Create worktree or checkout branch
BRANCH_NAME=$(gh pr view "$PR_NUMBER" --json headRefName -q .headRefName)
echo "📥 Checking out branch: $BRANCH_NAME"

# If worktrees are used
if git worktree list >/dev/null 2>&1; then
    WORKTREE_PATH="../trees/$BRANCH_NAME"
    if ! git worktree list | grep -q "$BRANCH_NAME"; then
        git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
    fi
    cd "$WORKTREE_PATH"
else
    # Regular checkout
    git checkout "$BRANCH_NAME"
fi

# Pull latest changes
git pull origin "$BRANCH_NAME"
```

### 3. Merge Latest Main/Master
```bash
# Get default branch name
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

echo "🔄 Merging latest $DEFAULT_BRANCH..."
git fetch origin
git merge origin/$DEFAULT_BRANCH

# Handle merge conflicts if any
if [ $? -ne 0 ]; then
    echo "⚠️  Merge conflicts detected. Please resolve them manually."
    git status
fi
```

### 4. Review and Implement Feedback
Review the PR for:
- **Code Quality**: Style, patterns, best practices
- **Testing**: Adequate test coverage
- **Documentation**: Updated docs if needed
- **Performance**: No obvious performance issues
- **Security**: No security vulnerabilities

Check PR comments:
```bash
# Get all review comments
echo "📝 Fetching review comments..."
gh pr view "$PR_NUMBER" --json reviews,comments -q '.reviews[].body, .comments[].body'
```

Implement requested changes:
1. Address each comment systematically
2. Run tests after each significant change
3. Commit with descriptive messages

### 5. Run Verification
```bash
# Run tests (adapt to project)
echo "🧪 Running tests..."
# Common test commands - use what applies
npm test 2>/dev/null || yarn test 2>/dev/null || pytest 2>/dev/null || go test ./... 2>/dev/null || cargo test 2>/dev/null

# Run linting/formatting
echo "🎨 Running linters..."
npm run lint 2>/dev/null || yarn lint 2>/dev/null || black . 2>/dev/null || gofmt -w . 2>/dev/null

# Build check
echo "🔨 Running build..."
npm run build 2>/dev/null || yarn build 2>/dev/null || make build 2>/dev/null
```

### 6. Update Documentation
Check if documentation needs updates:
- README.md for new features/changes
- CLAUDE.md for development workflow changes
- API documentation
- Code comments
- CHANGELOG.md or FEATURES.md

```bash
# Stage and commit documentation updates
git add -A
git commit -m "docs: Update documentation for PR feedback"
```

### 7. Push Changes
```bash
# Push all changes
echo "📤 Pushing changes..."
git push origin "$BRANCH_NAME"

# Add comment to PR
gh pr comment "$PR_NUMBER" --body "✅ Implemented requested changes:
- [List specific changes made]
- All tests passing
- Documentation updated
"
```

### 8. Final Review Checklist
```bash
echo "📋 Final Review Checklist:"
echo "✅ All feedback addressed"
echo "✅ Tests passing"
echo "✅ Code linted/formatted"
echo "✅ Documentation updated"
echo "✅ No merge conflicts"
echo ""
echo "🎯 Next steps:"
echo "1. Request re-review from original reviewers"
echo "2. Wait for approval"
echo "3. Once approved, run /cmd-pr-finalize"
```

## Purpose
This command helps:
- Systematically review and address PR feedback
- Ensure code quality before merge
- Keep PRs up-to-date with the main branch
- Document all changes properly

## Usage Examples
```bash
# Review PR by number
/cmd-pr-review 123

# Review PR by URL
/cmd-pr-review https://github.com/org/repo/pull/123

# Review specific branch
/cmd-pr-review --branch feature/new-feature
```