# Create Worktree

Create a new Git worktree for isolated feature development.

## Variables
- BRANCH_NAME: The name of your feature/branch (required)
- BRANCH_TYPE: The branch type - feature, bugfix, hotfix (default: feature)
- SETUP_TYPE: What to set up - full, frontend-backend, frontend-only, backend-only, backend-db

## Instructions

First, ask the user what kind of setup they need by presenting these options:

**What environment do you need for this work?**

1. **Full** (frontend + backend + database clone) - Complete isolation, use when changing DB schema
2. **Frontend + Backend** (no database clone) - Use shared dev database, fastest for most work
3. **Frontend only** - Just npm install, for pure UI work
4. **Backend only** - Just Python venv, for API-only changes
5. **Backend + Database** - Python + isolated database, for backend + schema changes

Based on the user's choice, run the worktree creation script with the appropriate flags:

```bash
# Full setup (frontend + backend + db)
.claude/scripts/worktree-create.sh "${BRANCH_TYPE:-feature}" "${BRANCH_NAME}" --full

# Frontend + Backend (no db clone)
.claude/scripts/worktree-create.sh "${BRANCH_TYPE:-feature}" "${BRANCH_NAME}" --frontend --backend

# Frontend only
.claude/scripts/worktree-create.sh "${BRANCH_TYPE:-feature}" "${BRANCH_NAME}" --frontend-only

# Backend only
.claude/scripts/worktree-create.sh "${BRANCH_TYPE:-feature}" "${BRANCH_NAME}" --backend-only

# Backend + Database
.claude/scripts/worktree-create.sh "${BRANCH_TYPE:-feature}" "${BRANCH_NAME}" --backend --db
```

## What Each Option Sets Up

| Option | Frontend (npm) | Backend (Python) | Database (clone) | Best For |
|--------|----------------|------------------|------------------|----------|
| Full | Yes | Yes | Yes | Schema changes, full isolation |
| Frontend + Backend | Yes | Yes | No (shared) | Most feature work |
| Frontend only | Yes | No | No | UI/styling changes |
| Backend only | No | Yes | No | API changes, no DB |
| Backend + Database | No | Yes | Yes | API + schema changes |

## After Creation

The script will:
1. Create the worktree in `trees/${BRANCH_NAME}`
2. Copy environment files (.env, credentials, etc.)
3. Initialize .claude submodule
4. Run selected setup steps **in parallel** for speed
5. Copy the `cd` command to your clipboard

**Important:** After the worktree is created, you must:
1. `cd trees/${BRANCH_NAME}` (already copied to clipboard)
2. Start a new Claude session: `claude`

## Usage Examples

```
User: /cmd-worktree-create
Assistant: What's the branch name?
User: auth-refactor
Assistant: What environment do you need?
  1. Full (frontend + backend + database)
  2. Frontend + Backend (shared database)
  3. Frontend only
  4. Backend only
  5. Backend + Database
User: 2
Assistant: [runs script with --frontend --backend]
```

## Cleanup

When done with a worktree, use `/cmd-issue-complete` or manually:
```bash
git worktree remove trees/${BRANCH_NAME}
git branch -d feature/${BRANCH_NAME}
# If database was cloned:
dropdb ${DB_NAME}_${BRANCH_NAME}
```
