#!/bin/bash

# protect-local-files.sh
# Protects critical local files from accidental git operations
# This script should be run after setting up the .claude submodule

set -e

echo "🛡️  Protecting local files from git operations..."

# Function to safely update git config
update_git_config() {
    local key="$1"
    local value="$2"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "⚠️  Not in a git repository, skipping git config"
        return
    fi
    
    # Update the local git config
    git config --local "$key" "$value"
    echo "✅ Set $key"
}

# Protect settings.local.json from being tracked
if [ -f "settings.local.json" ]; then
    # Tell git to ignore changes to this file if it's already tracked
    git update-index --skip-worktree settings.local.json 2>/dev/null || true
    echo "✅ Protected settings.local.json from git tracking"
fi

# Protect .env files from being tracked
for env_file in .env .env.local .env.production .env.development; do
    if [ -f "$env_file" ]; then
        git update-index --skip-worktree "$env_file" 2>/dev/null || true
        echo "✅ Protected $env_file from git tracking"
    fi
done

# Check parent directory for .env files too
if [ -f "../.env" ]; then
    (cd .. && git update-index --skip-worktree .env 2>/dev/null || true)
    echo "✅ Protected parent .env from git tracking"
fi

# Add git hooks to prevent accidental commits of protected files
HOOKS_DIR=".git/hooks"
if [ -d "$HOOKS_DIR" ] || [ -d "../.git/hooks" ]; then
    # Determine the correct hooks directory
    if [ -d "$HOOKS_DIR" ]; then
        TARGET_HOOKS="$HOOKS_DIR"
    else
        TARGET_HOOKS="../.git/hooks"
    fi
    
    # Create pre-commit hook
    cat > "$TARGET_HOOKS/pre-commit-protect" << 'EOF'
#!/bin/bash
# Pre-commit hook to protect sensitive files

# Check for .env files
if git diff --cached --name-only | grep -E '\.env(\.|$)'; then
    echo "❌ Error: Attempting to commit .env files!"
    echo "These files should never be committed:"
    git diff --cached --name-only | grep -E '\.env(\.|$)'
    echo ""
    echo "To remove from staging: git reset HEAD <file>"
    exit 1
fi

# Check for .claude directory modifications (except settings.local.json)
if git diff --cached --name-only | grep -E '^\.claude/' | grep -v 'settings\.local\.json'; then
    echo "❌ Error: Attempting to modify .claude submodule files!"
    echo "The .claude directory is a submodule and should not be modified directly."
    echo "Files attempting to be committed:"
    git diff --cached --name-only | grep -E '^\.claude/'
    echo ""
    echo "To contribute changes, submit a PR to the dot-claude repository."
    exit 1
fi

# Check for settings.local.json
if git diff --cached --name-only | grep 'settings\.local\.json'; then
    echo "⚠️  Warning: settings.local.json should not be committed"
    echo "This file contains project-specific settings."
    echo "To remove from staging: git reset HEAD settings.local.json"
    exit 1
fi
EOF
    
    chmod +x "$TARGET_HOOKS/pre-commit-protect"
    echo "✅ Created pre-commit protection hook"
    
    # Append to existing pre-commit hook or create new one
    if [ -f "$TARGET_HOOKS/pre-commit" ]; then
        # Check if our hook is already included
        if ! grep -q "pre-commit-protect" "$TARGET_HOOKS/pre-commit"; then
            echo "" >> "$TARGET_HOOKS/pre-commit"
            echo "# Run protection checks" >> "$TARGET_HOOKS/pre-commit"
            echo "if [ -f \"\$GIT_DIR/hooks/pre-commit-protect\" ]; then" >> "$TARGET_HOOKS/pre-commit"
            echo "    \$GIT_DIR/hooks/pre-commit-protect || exit 1" >> "$TARGET_HOOKS/pre-commit"
            echo "fi" >> "$TARGET_HOOKS/pre-commit"
            echo "✅ Added protection to existing pre-commit hook"
        fi
    else
        # Create new pre-commit hook
        cat > "$TARGET_HOOKS/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook

# Run protection checks
if [ -f "$GIT_DIR/hooks/pre-commit-protect" ]; then
    $GIT_DIR/hooks/pre-commit-protect || exit 1
fi
EOF
        chmod +x "$TARGET_HOOKS/pre-commit"
        echo "✅ Created new pre-commit hook with protection"
    fi
fi

echo ""
echo "🔒 Protection Summary:"
echo "• settings.local.json is protected from git tracking"
echo "• .env files are protected from git tracking and commits"
echo "• .claude submodule files are protected from modifications"
echo "• Pre-commit hooks installed to prevent accidental commits"
echo ""
echo "ℹ️  Note: These protections work with the deny rules in settings.local.json"
echo "   to provide multiple layers of safety for critical files."