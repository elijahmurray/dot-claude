# git-cleanup.md

Clean up merged branches and unused worktrees from the repository.

## Instructions

This command helps maintain a clean git environment by removing:
- Worktrees for branches that have been merged
- Local branches that have been merged into main
- Remote branches that have been merged
- Remote tracking branches that no longer exist
- Branch-specific databases that are no longer needed

### 0. Setup and Preparation
```bash
#!/bin/bash
set -euo pipefail
trap 'echo "❌ Cleanup failed at line $LINENO"' ERR

# Parse command line options
DRY_RUN="${1:-no}"
INTERACTIVE="${2:-yes}"

if [[ "$DRY_RUN" == "dry-run" ]] || [[ "$DRY_RUN" == "--dry-run" ]]; then
    echo "🔍 DRY RUN MODE - No changes will be made"
    DRY_RUN="yes"
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "⚠️  You have uncommitted changes. Please commit or stash them first:"
    echo "   git stash"
    exit 1
fi

echo "🔍 Preparing git cleanup..."

# Fetch all updates
git fetch --all --prune

# Get main branch name (could be 'main' or 'master')
MAIN_BRANCH=""

# Try multiple methods to detect main branch
if [ -z "$MAIN_BRANCH" ]; then
    MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || true)
fi

# Fallback: check which common branch names exist
if [ -z "$MAIN_BRANCH" ]; then
    for branch in main master; do
        if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
            MAIN_BRANCH="$branch"
            break
        fi
    done
fi

# Final fallback
if [ -z "$MAIN_BRANCH" ]; then
    MAIN_BRANCH="main"
fi

echo "ℹ️  Using main branch: $MAIN_BRANCH"

# Ensure we're on the main branch
git checkout "$MAIN_BRANCH" 2>/dev/null || git checkout main 2>/dev/null || git checkout master 2>/dev/null

# Update main branch to latest from origin
echo "📥 Updating $MAIN_BRANCH branch from origin..."
git pull origin "$MAIN_BRANCH" --ff-only || git reset --hard "origin/$MAIN_BRANCH"

# Protected branches that should never be deleted
PROTECTED_BRANCHES="main master develop staging production release"
```

### 1. Enhanced Merge Detection Function
```bash
# Function to check if a branch is merged (handles PR merges and modern workflows)
is_branch_merged() {
    local branch="$1"
    local base_branch="${2:-$MAIN_BRANCH}"
    local branch_name=$(basename "$branch")

    # Skip if branch is protected
    if echo "$PROTECTED_BRANCHES" | grep -qw "$branch_name"; then
        return 1
    fi

    # Method 1: Check traditional merge for local branches
    if [[ "$branch" != origin/* ]]; then
        if git branch --merged "$base_branch" 2>/dev/null | grep -q "^[* ]*$branch_name$"; then
            return 0
        fi
    fi

    # Method 2: For remote branches, check if remote branch is fully merged
    if [[ "$branch" == origin/* ]]; then
        # Check if the remote branch has no unique commits compared to base
        if [ -z "$(git rev-list "$base_branch".."$branch" 2>/dev/null)" ]; then
            return 0
        fi

        # Check commit count - if 0 commits ahead, it's merged
        local ahead_count=$(git rev-list --count "$base_branch".."$branch" 2>/dev/null || echo "1")
        if [ "$ahead_count" = "0" ]; then
            return 0
        fi
    else
        # For local branches, check against remote equivalent if it exists
        if git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
            # Check if remote branch is fully merged
            if [ -z "$(git rev-list "$base_branch"..origin/"$branch_name" 2>/dev/null)" ]; then
                return 0
            fi
        fi

        # Check if local branch's commits are in main (catches PR merges)
        if [ -z "$(git cherry "$base_branch" "$branch" 2>/dev/null | grep '^+')" ]; then
            return 0
        fi
    fi

    # Method 3: Check for PR merge commits in base branch
    # Look for merge commits that mention this branch
    if git log "$base_branch" --grep="$branch_name" --oneline -100 2>/dev/null | grep -qE "(Merge pull request|Merge branch|#[0-9]+).*$branch_name"; then
        return 0
    fi

    # Method 4: Check for squash/rebase merges by looking at commit messages
    # If all commits from the branch appear in main with same message, it was squashed
    if [[ "$branch" != origin/* ]]; then
        local branch_commits=$(git rev-list --count "$base_branch".."$branch" 2>/dev/null || echo "0")
        if [ "$branch_commits" -gt 0 ] && [ "$branch_commits" -lt 20 ]; then
            local branch_messages=$(git log --format="%s" "$base_branch".."$branch" 2>/dev/null)
            if [ -n "$branch_messages" ]; then
                local found_in_main=0
                local total_commits=0
                while IFS= read -r commit_msg; do
                    [ -z "$commit_msg" ] && continue
                    ((total_commits++))
                    if git log "$base_branch" --grep="$commit_msg" --oneline -1 2>/dev/null | grep -q "."; then
                        ((found_in_main++))
                    fi
                done <<< "$branch_messages"

                # If more than 60% of commit messages found in main, consider it merged
                if [ "$total_commits" -gt 0 ] && [ $((found_in_main * 100 / total_commits)) -gt 60 ]; then
                    return 0
                fi
            fi
        fi
    fi

    return 1
}

# Function to safely delete with confirmation
safe_delete() {
    local item_type="$1"  # branch, worktree, database, etc.
    local item_name="$2"
    local delete_command="$3"
    
    if [[ "$DRY_RUN" == "yes" ]]; then
        echo "[DRY RUN] Would delete $item_type: $item_name"
        return 0
    fi
    
    if [[ "$INTERACTIVE" == "yes" ]]; then
        read -p "Delete $item_type '$item_name'? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "   ⏭️  Skipped $item_type: $item_name"
            return 1
        fi
    fi
    
    echo "   🗑️  Deleting $item_type: $item_name"
    eval "$delete_command"
}
```

### 2. Find and Clean Merged Worktrees
```bash
echo ""
echo "🔍 Checking for worktrees to clean up..."

# List all worktrees
WORKTREES=$(git worktree list --porcelain 2>/dev/null | grep "^worktree" | cut -d' ' -f2)
WORKTREE_COUNT=0

# Check each worktree
for WORKTREE in $WORKTREES; do
    # Skip main worktree
    if [[ "$WORKTREE" == "$(git rev-parse --show-toplevel)" ]]; then
        continue
    fi
    
    if [[ "$WORKTREE" == *"/trees/"* ]] || [[ -d "$WORKTREE" ]]; then
        # Get branch name from worktree
        BRANCH=$(cd "$WORKTREE" 2>/dev/null && git branch --show-current || echo "")
        
        if [ -z "$BRANCH" ]; then
            echo "⚠️  Could not determine branch for worktree: $WORKTREE"
            continue
        fi
        
        # Check if branch is merged
        if is_branch_merged "$BRANCH"; then
            echo "🧹 Found merged worktree: $WORKTREE (branch: $BRANCH)"
            if safe_delete "worktree" "$WORKTREE" "git worktree remove '$WORKTREE' --force"; then
                ((WORKTREE_COUNT++))
            fi
        else
            echo "ℹ️  Keeping worktree: $WORKTREE (branch: $BRANCH - not merged)"
        fi
    fi
done

if [ $WORKTREE_COUNT -eq 0 ]; then
    echo "✅ No merged worktrees to clean up"
else
    echo "✅ Cleaned up $WORKTREE_COUNT worktree(s)"
fi
```

### 3. Clean Merged Local Branches
```bash
echo ""
echo "🔍 Checking for merged local branches to clean up..."

# Get all local branches except current and protected
LOCAL_BRANCHES=$(git branch | sed 's/^[* +]*//' | grep -vE "^($MAIN_BRANCH)$" || true)
BRANCH_COUNT=0

if [ -n "$LOCAL_BRANCHES" ]; then
    while IFS= read -r BRANCH; do
        BRANCH=$(echo "$BRANCH" | xargs)  # Trim whitespace
        [ -z "$BRANCH" ] && continue

        # Check if branch is merged
        if is_branch_merged "$BRANCH"; then
            echo "🗑️  Found merged branch: $BRANCH"
            if safe_delete "local branch" "$BRANCH" "git branch -D '$BRANCH' 2>/dev/null"; then
                ((BRANCH_COUNT++))
            fi
        else
            echo "ℹ️  Keeping branch: $BRANCH (not merged)"
        fi
    done <<< "$LOCAL_BRANCHES"
else
    echo "✅ No local branches to check"
fi

if [ $BRANCH_COUNT -eq 0 ]; then
    echo "✅ No merged local branches to clean up"
else
    echo "✅ Cleaned up $BRANCH_COUNT local branch(es)"
fi
```

### 4. Clean Merged Remote Branches
```bash
echo ""
echo "🔍 Checking for merged remote branches to clean up..."

# Get all remote branches except main/master
REMOTE_BRANCHES=$(git branch -r | sed 's/^[[:space:]*+]*//' | grep -v HEAD | grep -vE "^origin/($MAIN_BRANCH|master|main)$" || true)
REMOTE_COUNT=0

if [ -n "$REMOTE_BRANCHES" ]; then
    while IFS= read -r BRANCH; do
        BRANCH=$(echo "$BRANCH" | xargs)
        [ -z "$BRANCH" ] && continue
        BRANCH_NAME=${BRANCH#origin/}

        # Skip protected branches
        if echo "$PROTECTED_BRANCHES" | grep -qw "$BRANCH_NAME"; then
            echo "⚠️  Skipping protected branch: $BRANCH"
            continue
        fi

        # Check if branch is merged
        if is_branch_merged "$BRANCH"; then
            echo "🗑️  Found merged remote branch: $BRANCH"
            if safe_delete "remote branch" "$BRANCH" "git push origin --delete '$BRANCH_NAME' 2>/dev/null"; then
                ((REMOTE_COUNT++))
            fi
        fi
    done <<< "$REMOTE_BRANCHES"
else
    echo "✅ No remote branches to check"
fi

if [ $REMOTE_COUNT -eq 0 ]; then
    echo "✅ No merged remote branches to clean up"
else
    echo "✅ Cleaned up $REMOTE_COUNT remote branch(es)"
fi
```

### 5. Clean Branch Databases
```bash
echo ""
echo "🗄️  Checking for branch databases to clean up..."

# Enhanced database detection function
detect_main_database() {
    # Check environment variables in order of preference
    for env_file in ".env" ".env.local" ".env.development" "backend/.env" "app/.env" "api/.env"; do
        if [ -f "$env_file" ]; then
            # Try multiple patterns
            local db_url=$(grep -E "^DATABASE_URL=" "$env_file" 2>/dev/null | head -1)
            if [ -n "$db_url" ]; then
                # Extract database name from various URL formats
                local db_name=$(echo "$db_url" | sed -E 's|.*://[^/]*/([^?#"\s]*).*|\1|' | sed 's|"||g' | xargs)
                if [ -n "$db_name" ] && [ "$db_name" != "DATABASE_URL" ]; then
                    echo "$db_name"
                    return 0
                fi
            fi
            
            # Also check for DB_NAME or DATABASE_NAME patterns
            local db_name=$(grep -E "^(DB_NAME|DATABASE_NAME|POSTGRES_DB)=" "$env_file" 2>/dev/null | head -1 | cut -d'=' -f2 | sed 's|"||g' | xargs)
            if [ -n "$db_name" ]; then
                echo "$db_name"
                return 0
            fi
        fi
    done
    
    # Fallback: try to detect from current psql databases
    if command -v psql &> /dev/null; then
        local main_db=$(PGPASSWORD="${PGPASSWORD:-postgres}" psql -U "${PGUSER:-postgres}" -h "${PGHOST:-localhost}" -lqt 2>/dev/null | 
                        cut -d \| -f 1 | xargs | tr ' ' '\n' |
                        grep -E "^(app|main|project|production|development)_?db" | 
                        head -1)
        if [ -n "$main_db" ]; then
            echo "$main_db"
            return 0
        fi
    fi
    
    return 1
}

if command -v psql &> /dev/null; then
    MAIN_DB_NAME=$(detect_main_database || true)
    DB_COUNT=0
    
    if [ -n "$MAIN_DB_NAME" ]; then
        echo "ℹ️  Detected main database: $MAIN_DB_NAME"
        
        # Find all databases that match the pattern: main_db_branchname
        BRANCH_DBS=$(PGPASSWORD="${PGPASSWORD:-postgres}" psql -U "${PGUSER:-postgres}" -h "${PGHOST:-localhost}" -p "${PGPORT:-5432}" -lqt 2>/dev/null | 
                     cut -d \| -f 1 | xargs | tr ' ' '\n' |
                     grep -E "^${MAIN_DB_NAME}_" | xargs)
        
        if [ -n "$BRANCH_DBS" ]; then
            echo "Found branch databases:"
            for DB in $BRANCH_DBS; do
                # Extract branch name from database name
                BRANCH_FROM_DB=$(echo "$DB" | sed "s/^${MAIN_DB_NAME}_//")
                
                # Check if the branch still exists (local or remote)
                if ! git branch -a 2>/dev/null | grep -qE "(^|/)${BRANCH_FROM_DB}$"; then
                    echo "🗑️  Database $DB (branch: $BRANCH_FROM_DB no longer exists)"
                    
                    DELETE_CMD="PGPASSWORD='${PGPASSWORD:-postgres}' dropdb -U '${PGUSER:-postgres}' -h '${PGHOST:-localhost}' -p '${PGPORT:-5432}' '$DB' 2>/dev/null"
                    
                    if safe_delete "database" "$DB" "$DELETE_CMD"; then
                        ((DB_COUNT++))
                    fi
                else
                    echo "ℹ️  Keeping database $DB (branch: $BRANCH_FROM_DB still exists)"
                fi
            done
        else
            echo "✅ No branch databases found to clean up"
        fi
        
        if [ $DB_COUNT -gt 0 ]; then
            echo "✅ Cleaned up $DB_COUNT database(s)"
        fi
    else
        echo "⚠️  Could not detect main database name - skipping database cleanup"
        echo "   To enable database cleanup, ensure your .env file contains DATABASE_URL or DB_NAME"
    fi
else
    echo "⚠️  PostgreSQL client not found - skipping database cleanup"
fi
```

### 6. Prune Remote Tracking Branches
```bash
echo ""
echo "🔍 Pruning remote tracking branches..."

# Prune remote branches
git remote prune origin
echo "✅ Pruned remote tracking references"
```

### 7. Garbage Collection
```bash
echo ""
echo "🗑️  Running git garbage collection..."
git gc --auto
```

### 8. Summary Report
```bash
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🎉 Git cleanup completed!"
echo "═══════════════════════════════════════════════════════════════"

if [[ "$DRY_RUN" == "yes" ]]; then
    echo ""
    echo "🔍 This was a DRY RUN - no changes were made"
    echo "   Run without 'dry-run' argument to perform actual cleanup"
fi

echo ""
echo "📊 Current repository status:"
echo ""
echo "📁 Remaining worktrees:"
git worktree list | sed 's/^/   /'

echo ""
echo "🌿 Remaining local branches:"
git branch | sed 's/^/   /'

echo ""
echo "🌐 Remote branches (showing first 10):"
git branch -r | head -10 | sed 's/^/   /'
REMOTE_TOTAL=$(git branch -r | wc -l)
if [ "$REMOTE_TOTAL" -gt 10 ]; then
    echo "   ... and $((REMOTE_TOTAL - 10)) more"
fi

echo ""
echo "💡 Recovery Tips:"
echo "   • Deleted branches can be recovered using:"
echo "     git reflog | grep <branch-name>"
echo "     git checkout -b <branch-name> <commit-hash>"
echo "   • View all references: git show-ref"
echo "   • Restore from remote: git fetch origin <branch-name>"

echo ""
echo "🔧 Maintenance Tips:"
echo "   • Run with 'dry-run' argument to preview changes"
echo "   • Run with 'dry-run no' to skip confirmation prompts"
echo "   • Update your main branch regularly: git pull origin $MAIN_BRANCH"
echo "   • Clean up periodically to maintain repository health"
```

## Purpose
This enhanced command helps maintain a clean development environment by:
- **Updating main branch first** to ensure accurate merge detection
- **Detecting PR-based merges** including squash, rebase, and traditional merges
- **Properly handling remote branch merge detection** for modern workflows
- **Robust main branch detection** with multiple fallback methods
- **Fixed branch parsing** to handle git formatting symbols correctly
- **Improved loop handling** to prevent concatenation issues
- Removing worktrees for completed features
- Deleting local and remote branches that have been merged
- Cleaning up branch-specific databases
- Providing dry-run mode for safe preview
- Offering interactive confirmations for destructive operations
- Keeping the repository organized and efficient

## Usage Examples
```bash
# Preview what would be cleaned (dry run)
/cmd-git-cleanup dry-run

# Run cleanup with confirmations
/cmd-git-cleanup

# Run cleanup without confirmations (auto-yes)
/cmd-git-cleanup no no

# Run dry-run without confirmations
/cmd-git-cleanup dry-run no
```

## Options
- **First argument**: `dry-run` or `--dry-run` to preview without making changes
- **Second argument**: `no` to skip interactive confirmations (auto-yes mode)

## Important Notes
- Always fetches and updates main branch before checking merge status
- Detects branches merged via Pull Requests (squash, rebase, or merge)
- Protects important branches (main, master, develop, staging, production)
- Provides recovery information for accidentally deleted branches
- Checks for uncommitted changes before running
- Supports both 'main' and 'master' as primary branch names
- Safely handles database cleanup with multiple detection methods

## Troubleshooting
If branches aren't being detected as merged:
1. Ensure your main branch is up-to-date: `git pull origin main`
2. Check if the branch was merged via PR: `git log --grep="branch-name"`
3. Verify merge status manually: `git branch --merged main`
4. For squashed PRs, check: `git cherry main branch-name`