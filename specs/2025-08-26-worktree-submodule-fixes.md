# Worktree Submodule Fixes Feature Specification

**Date**: 2025-08-26  
**Feature**: worktree-submodule-fixes  
**Status**: Implemented  

## Overview

Fixed critical issues with git worktree creation when using .claude as a submodule, and enhanced PostgreSQL database setup to be more robust and compatible with different configurations.

## User Requirements

The user identified two major issues:

1. **Submodule Tracking Problem**: When creating worktrees, the script was copying .claude submodule content instead of properly initializing it, causing git to track submodule files as regular files in the worktree.

2. **PostgreSQL Connection Issues**: Database setup was failing due to hardcoded credentials and version-specific assumptions, making worktree creation unreliable across different PostgreSQL installations.

3. **README Conversion Issues**: The existing .claude to submodule conversion command was failing due to cached git submodule references.

## Technical Specifications

### Implementation Details

#### 1. Fixed .claude Submodule Initialization
**Before (broken approach):**
- Used `rsync -av --exclude='.git' "$PROJECT_ROOT/.claude/" ./.claude/`
- Copied submodule content, breaking the submodule relationship
- Git would track .claude files as regular files

**After (correct approach):**
- Uses `git submodule update --init --recursive`
- Properly initializes submodule in each worktree
- Only copies `settings.local.json` (the gitignored customization file)
- Maintains proper submodule relationship

#### 2. Enhanced PostgreSQL Database Setup
**Before (problematic):**
- Hardcoded `PGPASSWORD=postgres` and `-U postgres`
- Hardcoded `postgresql@14` service name
- Poor error handling and limited troubleshooting info

**After (improved):**
- Respects environment variables: `PGHOST`, `PGPORT`, `PGUSER`
- Falls back to sensible defaults (`localhost:5432`, current user)
- Tests connection with detected parameters
- Falls back to `postgres` user if current user fails
- Comprehensive error messages with troubleshooting steps
- Supports any PostgreSQL version

#### 3. Fixed README Submodule Conversion
**Enhanced one-liner command:**
```bash
git submodule deinit -f .claude 2>/dev/null; rm -rf .git/modules/.claude 2>/dev/null; cp .claude/settings.local.json settings.backup.json 2>/dev/null; git rm -rf .claude 2>/dev/null || rm -rf .claude; git submodule add https://github.com/elijahmurray/dot-claude.git .claude && cp settings.backup.json .claude/settings.local.json 2>/dev/null && rm -f settings.backup.json && git add .gitmodules .claude && git commit -m "Convert .claude to submodule"
```

### Files Modified/Created

**Modified:**
- `scripts/worktree-create.sh` - Fixed submodule initialization and database setup
- `README.md` - Updated submodule conversion instructions
- `settings.local.json.example` - Added comprehensive file protection rules

**Created:**
- `specs/2025-08-26-worktree-submodule-fixes.md` - This specification

### Key Decisions Made

1. **Use proper git submodule commands**: Never copy submodule content - always use `git submodule update --init --recursive`

2. **Preserve user customizations**: Continue copying `settings.local.json` as it contains project-specific settings that should be gitignored

3. **Flexible PostgreSQL connection**: Use environment variables with sensible defaults rather than hardcoded credentials

4. **Comprehensive error handling**: Provide detailed troubleshooting information for database connection issues

5. **Clean up cached submodule references**: Add `git submodule deinit` and remove `.git/modules/.claude` in conversion process

## Testing Requirements

- Test worktree creation with .claude as submodule
- Verify .claude files are not tracked in git after worktree creation
- Test PostgreSQL connection with various user configurations
- Verify database cloning works with different PostgreSQL setups
- Test README conversion command with existing .claude directories

## Dependencies

**Existing:**
- git (with worktree and submodule support)
- PostgreSQL client tools (psql, createdb, pg_isready)
- rsync (for other file copying operations)

**Environment Variables (optional):**
- `PGHOST` - PostgreSQL host (default: localhost)
- `PGPORT` - PostgreSQL port (default: 5432) 
- `PGUSER` - PostgreSQL user (default: current system user)

## Future Considerations

1. **Additional database support**: Could extend to support MySQL, SQLite, or other databases
2. **Submodule branch management**: Could add support for checking out specific submodule branches in worktrees
3. **Enhanced validation**: Could add checks to ensure submodule is properly initialized before proceeding
4. **Database migration automation**: Could automatically run detected migration commands after database cloning

## Implementation Notes

### Critical Fix Details

The core issue was in this section of `worktree-create.sh`:

```bash
# OLD (broken):
rsync -av --exclude='.git' "$PROJECT_ROOT/.claude/" ./.claude/

# NEW (correct):
git submodule update --init --recursive
cp "$PROJECT_ROOT/.claude/settings.local.json" ./.claude/settings.local.json
```

### PostgreSQL Connection Detection

The script now uses this detection order:
1. Try with environment variables (`PGHOST`, `PGPORT`, `PGUSER`)
2. Fall back to defaults (localhost:5432, current user)
3. If current user fails, try postgres user
4. Provide comprehensive error messages if all fail

### Submodule Conversion Cleanup

The enhanced conversion process:
1. Deinitializes existing submodule references
2. Removes cached git directories
3. Backs up settings before removal
4. Properly removes from git index
5. Adds fresh submodule
6. Restores user settings

This ensures clean conversion without git index conflicts.
