# pr-create.md

Create a pull request after ensuring all documentation is complete.

## Variables
- BRANCH_NAME: The feature branch name (optional, defaults to current branch)
- PR_TITLE: Title for the pull request (optional)
- PR_BODY: Body text for the pull request (optional)

## Instructions

This command creates a PR using GitHub CLI after verifying documentation is complete.

### 1. Pre-flight Checks
```bash
# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
FEATURE_BRANCH=${BRANCH_NAME:-$CURRENT_BRANCH}

# Ensure we're not on main
if [ "$FEATURE_BRANCH" == "main" ]; then
    echo "❌ Cannot create PR from main branch"
    exit 1
fi

echo "🔍 Creating PR for branch: $FEATURE_BRANCH"
```

### 2. Verify Documentation Exists
```bash
# Check for feature specification
SPEC_FILES=$(find specs/ -name "*${FEATURE_BRANCH}*" -o -name "*$(date +%Y-%m-%d)*" | head -n 1)
if [ -z "$SPEC_FILES" ]; then
    echo "❌ No specification found for this feature"
    echo "📝 Run /cmd-feature-document first to create documentation"
    exit 1
fi

# Check recent commits for documentation updates
RECENT_DOCS=$(git log --oneline -n 10 --grep="docs:" | head -n 1)
if [ -z "$RECENT_DOCS" ]; then
    echo "⚠️  No recent documentation commits found"
    echo "📝 Have you run /cmd-feature-document?"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✅ Documentation appears to be complete"
```

### 3. Push Latest Changes
```bash
# Ensure all changes are committed
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ You have uncommitted changes"
    echo "Please commit or stash them before creating a PR"
    git status --short
    exit 1
fi

# Push to remote
echo "📤 Pushing branch to remote..."
git push -u origin "$FEATURE_BRANCH"
```

### 4. Create Pull Request
```bash
# Generate PR title if not provided
if [ -z "$PR_TITLE" ]; then
    # Use the branch name or recent commit message
    LAST_COMMIT=$(git log -1 --pretty=%s)
    PR_TITLE="${LAST_COMMIT}"
fi

# Generate PR body
if [ -z "$PR_BODY" ]; then
    PR_BODY=$(cat <<EOF
## Summary
${LAST_COMMIT}

## Changes
- See commits for detailed changes
- Documentation has been updated in:
  - Feature specification in \`specs/\`
  - FEATURES.md changelog
  - README.md (if applicable)
  - CLAUDE.md (if applicable)

## Testing
- [ ] Tests pass locally
- [ ] Code has been linted
- [ ] Documentation is complete

## Related Issue
Closes #[issue-number]
EOF
)
fi

# Create the PR
echo "🚀 Creating pull request..."
gh pr create \
    --base main \
    --head "$FEATURE_BRANCH" \
    --title "$PR_TITLE" \
    --body "$PR_BODY"

# Get PR URL
PR_URL=$(gh pr view "$FEATURE_BRANCH" --json url -q .url)
```

### 5. Summary
```bash
echo ""
echo "✅ Pull request created successfully!"
echo "🔗 PR URL: $PR_URL"
echo ""
echo "📋 Next steps:"
echo "1. Review the PR on GitHub"
echo "2. Request reviews from team members"
echo "3. Run /cmd-pr-finalize for final checks"
echo "4. Merge when approved"
echo "5. Run /cmd-issue-complete after merge"
```

## Purpose
This command creates a pull request while ensuring:
- Documentation has been completed first
- All changes are pushed to remote
- PR includes proper description and references
- Clear next steps are provided

## Usage Examples
```bash
# Create PR for current branch
/cmd-pr-create

# Create PR with custom title
/cmd-pr-create --title "Add user authentication feature"

# Create PR for specific branch
/cmd-pr-create feature/oauth-integration
```