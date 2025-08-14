# Feature Specification: PostgreSQL Database Isolation for Worktrees

## Overview
Implemented automatic PostgreSQL database cloning for worktrees, allowing each feature branch to have its own isolated database copy for safe schema changes and migrations without affecting the main database.

## User Requirements
- Each worktree should have its own database clone for safe development
- Environment variables should automatically point to the branch-specific database
- Databases should be cleaned up when branches are merged
- Should work with existing PostgreSQL setups without manual configuration
- Should provide migration guidance for new databases

## Technical Specifications

### Database Detection and Cloning
- Auto-detects main database name from common environment files:
  - `.env`, `backend/.env`, `frontend/.env.local`
  - Supports `DATABASE_URL` and `DB_NAME` patterns
- Creates branch-specific database using naming convention: `{main_db}_{branch_name}`
- Uses PostgreSQL's `createdb -T` for efficient template-based cloning
- Inherits same user credentials and connection settings

### Environment Variable Updates
- Automatically updates database references in copied environment files
- Updates both `DATABASE_URL` and `DB_NAME` patterns
- Preserves all other environment configuration

### Migration Support
- Detects common migration frameworks:
  - Alembic (Python)
  - npm scripts with "migrate"
- Provides guidance on running migrations for the new database
- Does not auto-run migrations for safety

### Database Cleanup
- Added to `/cmd-git-cleanup`: Cleans databases for deleted branches
- Added to `/cmd-issue-complete`: Cleans database when completing an issue
- Includes safety confirmation prompts before dropping databases
- Only removes databases for branches that no longer exist

## Files Modified/Created

### Modified Commands
- `commands/cmd-worktree-create.md` - Added database cloning logic
- `commands/cmd-git-cleanup.md` - Added database cleanup for deleted branches
- `commands/cmd-issue-complete.md` - Added database cleanup for completed issues

### Modified Documentation
- `CLAUDE.md` - Added database isolation section
- `DEV_EXPERIENCE_CHANGELOG.md` - Documented the new feature

## Key Decisions Made

1. **PostgreSQL Only Initially**: Started with PostgreSQL support since it's the primary database used
2. **Template-based Cloning**: Used `createdb -T` for efficient copying with all data and schema
3. **Auto-detection**: Implemented smart detection to work without manual configuration
4. **Safety First**: Added confirmation prompts for all database deletion operations
5. **Migration Guidance**: Provided guidance rather than auto-running migrations to prevent accidents

## Testing Requirements
- Verify database detection from various environment file patterns
- Test database cloning with existing data and schema
- Confirm environment variable updates work correctly
- Test cleanup commands don't accidentally drop wrong databases
- Verify migration guidance appears for detected frameworks

## Dependencies
- PostgreSQL client tools (`psql`, `createdb`, `dropdb`)
- No new dependencies added to the codebase

## Future Considerations
- Support for other databases (MySQL, MongoDB, SQLite)
- Optional auto-migration running with safety checks
- Database backup before major migrations
- Integration with database migration rollback tools

## Implementation Notes

### Database Detection Logic
1. Checks common environment files in order of preference
2. Extracts database name from `DATABASE_URL` using regex
3. Falls back to `DB_NAME` if URL parsing fails
4. If no env files found, scans existing databases for likely candidates

### Error Handling
- Graceful degradation when PostgreSQL tools not available
- Clear error messages for failed database operations
- Continues worktree setup even if database cloning fails

### Security Considerations
- Uses same credentials as main database (temporary local development)
- No sensitive information logged in error messages
- Confirmation prompts prevent accidental data loss

## Usage Workflow

1. **Create Worktree**: `/cmd-worktree-create feature-name`
   - Automatically detects and clones database
   - Updates environment files
   - Provides migration guidance

2. **Develop with Isolation**: Work in worktree with separate database
   - Run migrations safely: `alembic upgrade head`
   - Test schema changes without affecting main

3. **Cleanup**: `/cmd-issue-complete` or `/cmd-git-cleanup`
   - Confirms before dropping branch database
   - Maintains clean development environment