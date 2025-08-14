# git-cleanup.md

Clean up merged branches and unused worktrees from the repository.

## Instructions

This command helps maintain a clean git environment by removing:
- Worktrees for branches that have been merged
- Local branches that have been merged into main
- Remote tracking branches that no longer exist
- Branch-specific databases that are no longer needed

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

### 3. Clean Branch Databases
```bash
echo "🗄️  Checking for branch databases to clean up..."

if command -v psql &> /dev/null; then
    # Try to detect main database name
    MAIN_DB_NAME=""
    
    # Check common env files for database name
    for env_file in ".env" "backend/.env" "frontend/.env.local"; do
        if [ -f "$env_file" ]; then
            # Look for DATABASE_URL or DB_NAME patterns
            DB_FROM_URL=$(grep -E "^DATABASE_URL=" "$env_file" 2>/dev/null | head -1 | sed -E 's|.*://[^/]*/([^?]*)\??.*|\1|')
            DB_FROM_NAME=$(grep -E "^DB_NAME=" "$env_file" 2>/dev/null | head -1 | cut -d'=' -f2)
            
            if [ -n "$DB_FROM_URL" ]; then
                MAIN_DB_NAME="$DB_FROM_URL"
                break
            elif [ -n "$DB_FROM_NAME" ]; then
                MAIN_DB_NAME="$DB_FROM_NAME"
                break
            fi
        fi
    done
    
    if [ -n "$MAIN_DB_NAME" ]; then
        # Find all databases that match the pattern: main_db_branchname
        BRANCH_DBS=$(PGPASSWORD=postgres psql -U postgres -h localhost -p 5432 -lqt 2>/dev/null | cut -d \| -f 1 | grep -E "^[[:space:]]*${MAIN_DB_NAME}_" | xargs)
        
        if [ -n "$BRANCH_DBS" ]; then
            echo "Found branch databases:"
            for DB in $BRANCH_DBS; do
                # Extract branch name from database name
                BRANCH_FROM_DB=$(echo "$DB" | sed "s/^${MAIN_DB_NAME}_//")
                
                # Check if the branch still exists
                if ! git branch -a | grep -q "$BRANCH_FROM_DB"; then
                    echo "🗑️  Database $DB (branch: $BRANCH_FROM_DB) - branch no longer exists"
                    read -p "   Drop database $DB? (y/N): " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        if PGPASSWORD=postgres dropdb -U postgres -h localhost -p 5432 "$DB" 2>/dev/null; then
                            echo "   ✅ Dropped database $DB"
                        else
                            echo "   ❌ Failed to drop database $DB"
                        fi
                    else
                        echo "   ⏭️  Skipped database $DB"
                    fi
                else
                    echo "ℹ️  Database $DB (branch: $BRANCH_FROM_DB) - branch still exists, keeping"
                fi
            done
        else
            echo "✅ No branch databases found to clean up"
        fi
    else
        echo "⚠️  Could not detect main database name - skipping database cleanup"
    fi
else
    echo "⚠️  PostgreSQL client not found - skipping database cleanup"
fi
```

### 4. Prune Remote Tracking Branches
```bash
echo "🔍 Pruning remote tracking branches..."

# Prune remote branches
git remote prune origin
```

### 5. Summary Report
```bash
echo ""
echo "🎉 Git cleanup completed!"
echo ""
echo "✅ Removed merged worktrees"
echo "✅ Deleted merged local branches"
echo "✅ Cleaned branch databases"
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
- Cleaning up branch-specific databases
- Keeping the repository organized and efficient

## Usage Examples
```bash
# Run cleanup
/cmd-git-cleanup

# Run after completing multiple features
/cmd-git-cleanup
```
