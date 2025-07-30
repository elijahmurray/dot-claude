# feature-document.md

Document the feature by creating a specification and updating all relevant documentation files.

## Variables
- FEATURE_NAME: The name of the feature being documented (defaults to current branch name)

## Instructions

This command ensures all documentation is complete BEFORE creating a PR. It handles:
1. Creating a feature specification
2. Updating FEATURES.md
3. Updating README.md (if needed)
4. Updating CLAUDE.md (if needed)

### 1. Determine Feature Name
```bash
# Get current branch name
CURRENT_BRANCH=$(git branch --show-current)
FEATURE_NAME=${FEATURE_NAME:-$(echo "$CURRENT_BRANCH" | sed 's/^feature\///')}

echo "📝 Documenting feature: $FEATURE_NAME"
```

### 2. Create Feature Specification
Create a comprehensive specification document from the development session:

```bash
# Generate the spec filename with current date
SPEC_DATE=$(date +%Y-%m-%d)
SPEC_FILE="specs/${SPEC_DATE}-${FEATURE_NAME}.md"

# Check if spec already exists
if [ -f "$SPEC_FILE" ]; then
    echo "✅ Specification already exists: $SPEC_FILE"
else
    echo "📝 Creating specification document..."
    # Analyze the entire conversation to extract requirements and implementation details
fi
```

The specification should include:
- **Overview**: Brief description of what was built
- **User Requirements**: All user inputs and requests from the session
- **Technical Specifications**: Implementation requirements and architecture decisions
- **Files Modified/Created**: List of all changed files
- **Key Decisions Made**: Important technical or design decisions
- **Testing Requirements**: Testing specifications mentioned
- **Dependencies**: External libraries, APIs, or services used
- **Future Considerations**: Any mentioned enhancements
- **Implementation Notes**: Key details needed to recreate the work

### 3. Determine Change Type and Update Appropriate Changelog
```bash
# Check if changes are developer-focused
DEV_PATTERNS=".claude/|scripts/|test_|jest|pytest|CLAUDE.md|DATABASE_SETUP|AUTHENTICATION_SETUP|requirements-dev|package-lock|tsconfig|eslint|prettier|.gitignore|Makefile|docker|.env.example|go.mod|Cargo.toml|composer.json|build.gradle"
USER_PATTERNS="src/|app/|lib/|pkg/|internal/|public/|components/|services/|api/|controllers/|models/|views/|domain/|core/"

# Get list of changed files
CHANGED_FILES=$(git diff --name-only main...HEAD)

# Determine if changes are primarily developer-focused
IS_DEV_CHANGE=false
for file in $CHANGED_FILES; do
    if echo "$file" | grep -qE "$DEV_PATTERNS"; then
        IS_DEV_CHANGE=true
        break
    fi
done

if [ "$IS_DEV_CHANGE" = true ]; then
    echo "📝 Updating DEVELOPER_EXPERIENCE.md (developer-focused changes detected)..."
    TARGET_CHANGELOG="DEVELOPER_EXPERIENCE.md"
else
    echo "📝 Updating FEATURES.md or CHANGELOG.md (user-facing changes)..."
    # Check which changelog file exists
    if [ -f "CHANGELOG.md" ]; then
        TARGET_CHANGELOG="CHANGELOG.md"
    else
        TARGET_CHANGELOG="FEATURES.md"
    fi
fi
```

Add entry following this format:
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- **Feature Name**: Description of new functionality
  - Sub-feature or detail
  - Another sub-feature

### Fixed
- **Issue Description**: What was fixed and why

### Updated
- **Component Name**: What was changed
```

### 4. Update README.md (if applicable)
Check if README needs updates for:
- New user-facing functionality
- New setup requirements
- New usage examples
- New dependencies
- Architecture changes
- New API endpoints

```bash
echo "🔍 Checking if README.md needs updates..."
# Review changes to determine if README updates are needed
```

### 5. Update CLAUDE.md (if applicable)
Check if CLAUDE.md needs updates for:
- New development commands
- New architecture components
- New setup requirements
- Common issues and solutions
- New essential commands
- New troubleshooting steps

```bash
echo "🔍 Checking if CLAUDE.md needs updates..."
# Review changes to determine if CLAUDE.md updates are needed
```

### 6. Commit Documentation
```bash
# Stage all documentation changes
git add specs/ FEATURES.md CHANGELOG.md DEVELOPER_EXPERIENCE.md README.md CLAUDE.md 2>/dev/null

# Check what was staged
STAGED_FILES=$(git diff --cached --name-only)
if [ -n "$STAGED_FILES" ]; then
    echo "📄 Staged documentation files:"
    echo "$STAGED_FILES"
    
    # Commit the documentation
    git commit -m "docs: Add documentation for $FEATURE_NAME feature"
    echo "✅ Documentation committed"
else
    echo "⚠️  No documentation changes to commit"
fi
```

### 7. Summary
```bash
echo ""
echo "📋 Documentation Summary:"
echo "✅ Feature specification created/verified"
if [ "$IS_DEV_CHANGE" = true ]; then
    echo "✅ DEVELOPER_EXPERIENCE.md updated (developer-focused changes)"
else
    echo "✅ FEATURES.md updated with changelog"
fi
echo "✅ README.md reviewed and updated if needed"
echo "✅ CLAUDE.md reviewed and updated if needed"
echo ""
echo "🎯 Next steps:"
echo "1. Review the documentation changes"
echo "2. Run /cmd-pr-create to create a pull request"
echo "3. The PR will include all documentation"
```

## Purpose
This command ensures comprehensive documentation is created BEFORE the PR, so that:
- The PR includes all documentation changes
- Nothing is forgotten or done as an afterthought
- Feature specifications are captured while context is fresh
- Documentation is part of the development process, not a separate task

## Usage Examples
```bash
# Document current feature branch
/cmd-feature-document

# Document with specific feature name
/cmd-feature-document user-authentication

# After completing development work
/cmd-feature-document google-calendar-integration
```