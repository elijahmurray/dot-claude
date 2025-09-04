#!/bin/bash

# feature-document.sh
# Automated feature documentation script

set -e

# Function to find project root (directory containing .git)
find_project_root() {
    local current_dir="$(pwd)"
    while [[ "$current_dir" != "/" ]]; do
        if [[ -d "$current_dir/.git" ]] || [[ -f "$current_dir/.git" ]]; then
            echo "$current_dir"
            return
        fi
        current_dir="$(dirname "$current_dir")"
    done
    echo "❌ Error: Not in a git repository" >&2
    exit 1
}

# Get project root and ensure we're in the right place
PROJECT_ROOT=$(find_project_root)
echo "📍 Working from: $(pwd)"

# Get parameters
FEATURE_NAME=${1:-""}

# 1. Determine Feature Name
echo "🔍 Determining feature name..."
CURRENT_BRANCH=$(git branch --show-current)
if [ -z "$FEATURE_NAME" ]; then
    FEATURE_NAME=$(echo "$CURRENT_BRANCH" | sed 's/^feature\///')
fi

echo "📝 Documenting feature: $FEATURE_NAME"

# 2. Create Feature Specification
echo ""
echo "📋 Creating feature specification..."

# Check if specs directory exists, create if needed
if [ ! -d "specs" ]; then
    echo "📁 Creating specs directory..."
    mkdir -p specs
else
    echo "📁 Specs directory already exists"
fi

# Generate the spec filename with current date
SPEC_DATE=$(date +%Y-%m-%d)
SPEC_FILE="specs/${SPEC_DATE}-${FEATURE_NAME}.md"

# Check if spec already exists
if [ -f "$SPEC_FILE" ]; then
    echo "✅ Specification already exists: $SPEC_FILE"
    echo "   Please review and update it if needed with the latest changes"
else
    echo "📝 Creating specification document: $SPEC_FILE"
    echo "   ⚠️  You'll need to fill in the specification content manually"
    echo "   The template structure will be created for you"
    
    # Create basic spec template
    cat > "$SPEC_FILE" << EOF
# $FEATURE_NAME Feature Specification

**Date**: $SPEC_DATE  
**Feature**: $FEATURE_NAME  
**Status**: In Progress  

## Overview

[Brief description of what was built]

## User Requirements

[All user inputs and requests from the session]

## Technical Specifications

### Implementation Details
[Implementation requirements and architecture decisions]

### Files Modified/Created
[List of all changed files]

### Key Decisions Made
[Important technical or design decisions]

## Testing Requirements

[Testing specifications mentioned]

## Dependencies

[External libraries, APIs, or services used]

## Future Considerations

[Any mentioned enhancements]

## Implementation Notes

[Key details needed to recreate the work]
EOF
    echo "✅ Created specification template"
fi

# 3. Determine Change Type and Update Appropriate Changelog
echo ""
echo "📊 Analyzing changes to determine documentation target..."

DEV_PATTERNS=".claude/|scripts/|test_|jest|pytest|CLAUDE.md|DATABASE_SETUP|AUTHENTICATION_SETUP|requirements-dev|package-lock|tsconfig|eslint|prettier|.gitignore|Makefile|docker|.env.example|go.mod|Cargo.toml|composer.json|build.gradle"
USER_PATTERNS="src/|app/|lib/|pkg/|internal/|public/|components/|services/|api/|controllers/|models/|views/|domain/|core/"

# Get list of changed files
CHANGED_FILES=$(git diff --name-only main...HEAD 2>/dev/null || echo "")

if [ -n "$CHANGED_FILES" ]; then
    echo "📄 Changed files:"
    echo "$CHANGED_FILES" | sed 's/^/  - /'
    
    # Determine if changes are primarily developer-focused
    IS_DEV_CHANGE=false
    for file in $CHANGED_FILES; do
        if echo "$file" | grep -qE "$DEV_PATTERNS"; then
            IS_DEV_CHANGE=true
            break
        fi
    done
else
    echo "⚠️  No changed files detected (comparing to main branch)"
    echo "   Defaulting to developer-focused changelog"
    IS_DEV_CHANGE=true
fi

if [ "$IS_DEV_CHANGE" = true ]; then
    echo "📝 Target: DEVELOPER_EXPERIENCE.md (developer-focused changes detected)"
    TARGET_CHANGELOG="DEVELOPER_EXPERIENCE.md"
else
    echo "📝 Target: User-facing changelog (user-facing changes detected)"
    # Check which changelog file exists
    if [ -f "CHANGELOG.md" ]; then
        TARGET_CHANGELOG="CHANGELOG.md"
        echo "   Using: CHANGELOG.md"
    else
        TARGET_CHANGELOG="FEATURES.md"
        echo "   Using: FEATURES.md"
    fi
fi

# Create changelog entry template
CHANGELOG_DATE=$(date +%Y-%m-%d)
CHANGELOG_ENTRY="## [X.Y.Z] - $CHANGELOG_DATE

### Added
- **$FEATURE_NAME**: [Description of new functionality]
  - [Sub-feature or detail]
  - [Another sub-feature]

### Fixed
- **[Issue Description]**: [What was fixed and why]

### Updated
- **[Component Name]**: [What was changed]"

echo ""
echo "📝 Changelog entry template:"
echo "$CHANGELOG_ENTRY"
echo ""
echo "⚠️  You'll need to manually add this entry to $TARGET_CHANGELOG"

# 4. Update README.md (if applicable)
echo ""
echo "🔍 Checking if README.md needs updates..."
echo "   Review if changes require README.md updates for:"
echo "   - New user-facing functionality"
echo "   - New setup requirements"
echo "   - New usage examples"
echo "   - New dependencies"
echo "   - Architecture changes"
echo "   - New API endpoints"

# 5. Update CLAUDE.md (if applicable)
echo ""
echo "🔍 Checking if CLAUDE.md needs updates..."
echo "   Review if changes require CLAUDE.md updates for:"
echo "   - New development commands"
echo "   - New architecture components"
echo "   - New setup requirements"
echo "   - Common issues and solutions"
echo "   - New essential commands"
echo "   - New troubleshooting steps"

# 6. Commit Documentation (dry run first)
echo ""
echo "📦 Checking for documentation changes to commit..."

# Check what documentation files exist and might need staging
DOC_FILES="specs/ FEATURES.md CHANGELOG.md DEVELOPER_EXPERIENCE.md README.md CLAUDE.md"
EXISTING_DOC_FILES=""

for file in $DOC_FILES; do
    if [ -f "$file" ] || [ -d "$file" ]; then
        EXISTING_DOC_FILES="$EXISTING_DOC_FILES $file"
    fi
done

if [ -n "$EXISTING_DOC_FILES" ]; then
    echo "📄 Documentation files found:$EXISTING_DOC_FILES"
    echo ""
    echo "🔄 Staging documentation changes..."
    
    # Stage documentation files (suppress errors for non-existent files)
    git add $EXISTING_DOC_FILES 2>/dev/null || true
    
    # Check what was actually staged
    STAGED_FILES=$(git diff --cached --name-only)
    if [ -n "$STAGED_FILES" ]; then
        echo "📄 Staged documentation files:"
        echo "$STAGED_FILES" | sed 's/^/  - /'
        echo ""
        
        # Commit the documentation
        echo "💾 Committing documentation..."
        git commit -m "docs: Add documentation for $FEATURE_NAME feature"
        echo "✅ Documentation committed"
    else
        echo "⚠️  No documentation changes to commit"
    fi
else
    echo "⚠️  No documentation files found to stage"
fi

# 7. Summary
echo ""
echo "📋 Documentation Summary:"
echo "✅ Feature specification created/verified: $SPEC_FILE"
if [ "$IS_DEV_CHANGE" = true ]; then
    echo "📝 Target changelog: DEVELOPER_EXPERIENCE.md (developer-focused changes)"
else
    echo "📝 Target changelog: $TARGET_CHANGELOG (user-facing changes)"
fi
echo "🔍 README.md reviewed - manual updates may be needed"
echo "🔍 CLAUDE.md reviewed - manual updates may be needed"
echo ""
echo "🎯 Next steps:"
echo "1. Review and complete the specification: $SPEC_FILE"
echo "2. Add changelog entry to: $TARGET_CHANGELOG"
echo "3. Update README.md and CLAUDE.md if needed"
echo "4. Run /cmd-pr-create to create a pull request"
echo "5. The PR will include all documentation"
echo ""
echo "✨ Feature documentation workflow complete!"