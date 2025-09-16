# worktree-env-improvements Feature Specification

**Date**: 2025-09-16
**Feature**: worktree-env-improvements
**Status**: Completed

## Overview

Enhanced the worktree creation script to dynamically discover and copy all environment configuration files, replacing the previous hardcoded approach that missed critical files in subdirectories.

## User Requirements

- Fix authentication failures in worktrees caused by missing environment variables
- Make the worktree script generic and robust for any project structure
- Ensure all `.env` files are copied, not just hardcoded paths
- Support various project layouts without modification

## Technical Specifications

### Implementation Details
- Replaced hardcoded file copying with dynamic file discovery using `find`
- Maintains original directory structure when copying files
- Automatically handles `.env.example` templates as fallback
- Discovers and copies additional configuration files (credentials, secrets, local configs)
- Excludes build and dependency directories from search

### Files Modified/Created
- `scripts/worktree-create.sh` - Updated environment file copying logic (lines 51-144)

### Key Decisions Made
- Used `find` command for dynamic file discovery instead of hardcoding paths
- Preserved directory structure to maintain project organization
- Added comprehensive exclusion patterns for build/dependency directories
- Included broader search for configuration files beyond just `.env` files

## Testing Requirements

- Verify script syntax with `bash -n`
- Test with projects having different structures:
  - Single `.env` at root
  - Multiple subdirectories with `.env` files
  - Projects with only `.env.example` templates
  - Projects with credentials and config files

## Dependencies

None - uses standard bash utilities (find, cp, mkdir)

## Future Considerations

- Could add configuration file to customize which patterns to include/exclude
- Consider adding dry-run mode to preview what would be copied
- Could detect and handle symlinked configuration files

## Implementation Notes

The new approach uses find with multiple patterns:
- `.env*` and `*.env` files throughout the project
- Excludes: node_modules, .git, trees, venv, __pycache__, dist, build
- Falls back to `.env.example` files if no actual .env files exist
- Additional search for credentials, secrets, and local config files
- Maintains directory structure using relative paths
