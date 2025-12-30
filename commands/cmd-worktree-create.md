# Create Worktree

Create a new Git worktree for isolated feature development.

## Variables
- TICKET_ID: The Linear ticket ID (e.g., RAI-270) - **REQUIRED**
- BRANCH_TYPE: The type (feature, fix, chore, hotfix) - default: feature
- DESCRIPTION: Short description (will be slugified)
- SETUP_TYPE: What to set up - full, frontend-backend, frontend-only, backend-only, backend-db

## Branch Naming Convention

**Format:** `{type}/{TICKET_ID}-{description}`

**Examples:**
- `feature/RAI-270-add-user-auth`
- `fix/RAI-271-login-timeout`
- `chore/RAI-272-update-deps`

**IMPORTANT:** Always include the ticket ID so Linear auto-links the branch.

## Instructions

### Step 1: Get Branch Info
Ask the user for:
1. **Ticket ID** (required) - e.g., RAI-270
2. **Branch type** - feature, fix, chore, hotfix (default: feature)
3. **Short description** - 3-5 words for the branch name

### Step 2: Ask What Setup They Need

**What environment do you need for this work?**

1. **Full** (frontend + backend + database clone) - Complete isolation, use when changing DB schema
2. **Frontend + Backend** (no database clone) - Use shared dev database, fastest for most work
3. **Frontend only** - Just npm install, for pure UI work
4. **Backend only** - Just Python venv, for API-only changes
5. **Backend + Database** - Python + isolated database, for backend + schema changes

### Step 3: Check for Workers (if backend selected)

If the project has Celery/Redis workers (check for `celery.py`, `tasks.py`, or `worker` in the codebase), ask:

**Do you need background workers for this work?**
- Yes - I'll be working with async tasks/Celery
- No - Skip worker setup

### Step 4: Run the Script

Based on choices, run the worktree creation script:

```bash
# Full setup (frontend + backend + db)
.claude/scripts/worktree-create.sh "${BRANCH_TYPE:-feature}" "${TICKET_ID}-${DESCRIPTION}" --full

# Frontend + Backend (no db clone)
.claude/scripts/worktree-create.sh "${BRANCH_TYPE:-feature}" "${TICKET_ID}-${DESCRIPTION}" --frontend --backend

# Frontend only
.claude/scripts/worktree-create.sh "${BRANCH_TYPE:-feature}" "${TICKET_ID}-${DESCRIPTION}" --frontend-only

# Backend only
.claude/scripts/worktree-create.sh "${BRANCH_TYPE:-feature}" "${TICKET_ID}-${DESCRIPTION}" --backend-only

# Backend + Database
.claude/scripts/worktree-create.sh "${BRANCH_TYPE:-feature}" "${TICKET_ID}-${DESCRIPTION}" --backend --db

# With workers (add to any backend option)
.claude/scripts/worktree-create.sh "${BRANCH_TYPE:-feature}" "${TICKET_ID}-${DESCRIPTION}" --backend --workers
```

## What Each Option Sets Up

| Option | Frontend | Backend | Database | Workers | Best For |
|--------|----------|---------|----------|---------|----------|
| Full | Yes | Yes | Clone | Optional | Schema changes, full isolation |
| Frontend + Backend | Yes | Yes | Shared | Optional | Most feature work |
| Frontend only | Yes | No | No | No | UI/styling changes |
| Backend only | No | Yes | No | Optional | API changes, no DB |
| Backend + Database | No | Yes | Clone | Optional | API + schema changes |

## Worker Support

If the project uses Celery/Redis, the `--workers` flag will:
- Check if Redis is running
- Provide commands to start Celery worker/beat
- Note: Workers run against the same database as the worktree

Common worker files to detect:
- `celery.py` or `**/celery.py`
- `tasks.py` or `**/tasks.py`
- `worker/` directory
- `CELERY_BROKER_URL` in .env

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
Assistant: What's the ticket ID?
User: RAI-270
Assistant: Branch type? (feature/fix/chore/hotfix)
User: feature
Assistant: Short description for branch name?
User: add-user-auth
Assistant: What environment do you need?
  1. Full (frontend + backend + database)
  2. Frontend + Backend (shared database)
  3. Frontend only
  4. Backend only
  5. Backend + Database
User: 2
Assistant: I see this project has Celery workers. Do you need workers for this work?
User: no
Assistant: [runs script: worktree-create.sh feature RAI-270-add-user-auth --frontend --backend]
```

## Cleanup

When done with a worktree, use `/cmd-issue-complete` or manually:
```bash
git worktree remove trees/${BRANCH_NAME}
git branch -d feature/${BRANCH_NAME}
# If database was cloned:
dropdb ${DB_NAME}_${BRANCH_NAME}
```
