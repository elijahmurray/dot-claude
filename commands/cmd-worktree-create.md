# worktree-create.md

Create a new Git worktree for parallel feature development.

## Variables
- BRANCH_TYPE: The type (feature, bugfix, hotfix)
- BRANCH_NAME: The name of your feature

## Instructions

Run the automated worktree setup script:
```bash
.claude/scripts/worktree-create.sh ${BRANCH_TYPE:-"feature"} ${BRANCH_NAME}
```

## What the Script Does

The worktree creation script handles all setup automatically:

1. **Creates the worktree** in `trees/${BRANCH_NAME}` directory
2. **Copies environment files** (.env, frontend/.env.local, etc.)
3. **Copies .claude directory** with all settings and commands (handles submodules properly)
4. **Installs dependencies** (Python venv + pip, npm install)
5. **Clones database** for isolated development (PostgreSQL)
6. **Updates environment variables** to point to branch database
7. **Provides migration guidance** for the new database

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

5. **Remember**:
   - This worktree is isolated from other branches
   - You can switch between worktrees without stashing
   - Each worktree maintains its own environment and database
   - Database cleanup happens automatically when branches are merged

Make sure to copy over the env files into the work tree. There's one for the top level directory and then also one for the backend folder. Also, ALWAYS make sure to create the work tree off of the top level directory. Not nested within an existing work tree.