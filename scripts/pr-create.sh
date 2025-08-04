#!/bin/bash

# pr-create.sh - Automated PR creation script
# Usage: pr-create.sh [branch_name] [pr_title]

set -e  # Exit on any error

# Parse arguments
BRANCH_NAME=$1
PR_TITLE=$2
PR_BODY=$3

# 1. Pre-flight Checks
echo "🔍 Starting PR creation process..."

# Check if gh CLI is installed (keeping GitHub for now per Option A)
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

# 2. Verify Documentation Exists
# Check for feature specification
SPEC_FILES=$(find specs/ -name "*${FEATURE_BRANCH}*" -o -name "*$(date +%Y-%m-%d)*" 2>/dev/null | head -n 1)
if [ -z "$SPEC_FILES" ]; then
    echo "❌ No specification found for this feature"
    echo "📝 Run /cmd-feature-document first to create documentation"
    exit 1
fi

# Check recent commits for documentation updates (skip manual prompt, just warn)
RECENT_DOCS=$(git log --oneline -n 10 --grep="docs:" | head -n 1)
if [ -z "$RECENT_DOCS" ]; then
    echo "⚠️  No recent documentation commits found"
    echo "📝 Continuing anyway, but consider running /cmd-feature-document"
fi

echo "✅ Documentation check complete"

# 3. Push Latest Changes
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

# 4. Create Pull Request
# Generate PR title if not provided
if [ -z "$PR_TITLE" ]; then
    LAST_COMMIT=$(git log -1 --pretty=%s)
    PR_TITLE="${LAST_COMMIT}"
fi

# Generate PR body if not provided
if [ -z "$PR_BODY" ]; then
    LAST_COMMIT=$(git log -1 --pretty=%s)
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

## Related Ticket
Closes [ticket-reference] <!-- Format depends on ticket system - see CLAUDE.md -->
EOF
)
fi

# Create the PR using GitHub CLI
echo "🚀 Creating pull request..."
gh pr create \
    --base main \
    --head "$FEATURE_BRANCH" \
    --title "$PR_TITLE" \
    --body "$PR_BODY"

# Get PR URL
PR_URL=$(gh pr view "$FEATURE_BRANCH" --json url -q .url)

# 5. Summary
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