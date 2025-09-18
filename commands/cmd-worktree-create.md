# worktree-create.md

Create a new Git worktree for parallel feature development.

## Variables
- BRANCH_TYPE: The type (feature, bugfix, hotfix)
- BRANCH_NAME: The name of your feature

## Instructions

Run the automated worktree setup script. The script will automatically detect the correct path regardless of your current directory:

```bash
# From project root
.claude/scripts/worktree-create.sh ${BRANCH_TYPE:-"feature"} ${BRANCH_NAME}

# From any subdirectory
../scripts/worktree-create.sh ${BRANCH_TYPE:-"feature"} ${BRANCH_NAME}

# Or let the script find itself
scripts/worktree-create.sh ${BRANCH_TYPE:-"feature"} ${BRANCH_NAME}
```

The script is pre-approved in settings.local.json and will run without bash command approvals.

## What the Script Does

The worktree creation script handles all setup automatically:

1. **Creates the worktree** in `trees/${BRANCH_NAME}` directory
2. **Copies environment files** (.env, frontend/.env.local, etc.)
3. **Copies .claude directory** with all settings and commands (handles submodules properly)
4. **Installs dependencies** with enhanced multi-directory support:
   - **Python**: Detects `requirements.txt` in root, backend/, api/, server/, app/, src/
   - **Node.js**: Installs from package.json in root or frontend/
   - **Creates virtual environments** in appropriate subdirectories
5. **Clones database** for isolated development (PostgreSQL)
6. **Updates environment variables** to point to branch database
7. **Provides migration guidance** for the new database
8. **Verifies environment setup** and provides troubleshooting guidance

## Next Steps

After creating a worktree:

1. **Start Development**:
   - Run `/cmd-issue-start` if you have an issue to implement
   - Or begin writing tests following TDD approach

2. **During Development**:
   - Write tests first (RED phase)
   - Implement features (GREEN phase)
   - Refactor and optimize (REFACTOR phase)
   - Commit regularly with descriptive messages

3. **Database Migrations**:
   - Run `alembic upgrade head` (for Python projects)
   - Run `npm run migrate` (for Node projects)
   - Test schema changes safely without affecting main database

4. **When Complete**:
   - Run `/cmd-feature-document` to create spec and update documentation
   - Merge your changes (PR or local merge)
   - Run `/cmd-issue-complete` to clean everything up

5. **Virtual Environment Activation**:
   - **Backend projects**: `cd backend && source venv/bin/activate`
   - **Root-level Python**: `source venv/bin/activate`
   - **API projects**: `cd api && source venv/bin/activate`
   - **Multiple environments**: Each subdirectory with requirements.txt gets its own venv

6. **Troubleshooting Virtual Environment Issues**:
   ```bash
   # Check what environments were created
   ls -la */venv 2>/dev/null || ls -la venv 2>/dev/null

   # If backend venv is missing, create manually:
   cd backend && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt

   # Common activation patterns:
   cd backend && source venv/bin/activate  # For backend/requirements.txt
   source venv/bin/activate                # For root requirements.txt
   ```

7. **Remember**:
   - This worktree is isolated from other branches
   - You can switch between worktrees without stashing
   - Each worktree maintains its own environment and database
   - Virtual environments are created in the same directory as requirements.txt
   - Database cleanup happens automatically when branches are merged
   - ALWAYS create worktrees from the top level directory, not nested within existing worktrees

## Common Project Structures Supported

The script automatically handles these project layouts:

```
# Full-stack with backend subdirectory
project/
├── backend/requirements.txt → Creates backend/venv/
├── frontend/package.json    → Runs npm install
└── .env                     → Copied to worktree

# Root-level Python project
project/
├── requirements.txt         → Creates venv/
├── app/                     → Python source code
└── .env                     → Copied to worktree

# Microservices structure
project/
├── api/requirements.txt     → Creates api/venv/
├── server/requirements.txt  → Creates server/venv/
└── frontend/package.json    → Runs npm install
```