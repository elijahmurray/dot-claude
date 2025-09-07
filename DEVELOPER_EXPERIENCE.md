# Developer Experience Changelog

This file tracks improvements to the development workflow, tooling, and developer experience for projects using the dot-claude template.

## [1.4.0] - 2025-09-06

### Added
- **Worktree Session Transition Enhancement**: Comprehensive guidance system for switching to new worktree directories
  - Prominent visual instructions with red-bordered warning box and color-coded steps
  - Automatic Warp Terminal tab creation with three fallback automation methods
  - Desktop notification integration using existing notification system
  - Copy-paste ready commands for manual execution
  - Terminal type detection for appropriate automation attempts
  - Pre-approved permissions for osascript, warp-cli, and terminal-notifier

### Enhanced
- **Worktree Creation Workflow**: Improved user experience to prevent working in wrong directory
  - Clear explanation of why session switching is critical
  - Multi-layered approach ensures users don't miss instructions
  - Graceful degradation for non-Warp terminals
  - Integration with existing notification infrastructure

## [1.3.1] - 2025-09-03

### Fixed
- **Python Command Detection**: Fixed worktree creation script failing on systems with only python3
  - Added automatic detection of available Python command (python3 or python)
  - Script now works on modern macOS and Linux where 'python' doesn't exist
  - Uses `$PYTHON_CMD -m pip` for better cross-platform compatibility
  - Provides clear error message if Python is not installed

## [1.3.0] - 2025-09-03

### Enhanced
- **Git Cleanup Command**: Major improvements to `/cmd-git-cleanup` for reliable branch detection
  - Now updates main branch before checking merge status (fixes 17-commit behind issue)
  - Detects branches merged via Pull Requests (squash, rebase, or merge)
  - Added remote branch cleanup functionality
  - Enhanced database detection with multiple fallback methods
  - Added dry-run mode for safe preview of changes
  - Interactive confirmations with opt-out option
  - Protected branches list (main, master, develop, staging, production)
  - Comprehensive error handling with line number reporting
  - Recovery information for accidentally deleted branches

### Fixed
- **Merge Detection Logic**: Fixed critical issue where PR-merged branches weren't detected
  - Added `git cherry` and `git rev-list` checks for squashed PRs
  - Search git log for merge commits mentioning branch names
  - Properly handles both direct merges and GitHub PR workflows

### Added
- **Git Cleanup Script**: Created standalone `scripts/git-cleanup.sh` for testing
  - Executable script with all enhancements from command
  - Support for dry-run and non-interactive modes
  - Can be run directly: `./scripts/git-cleanup.sh dry-run`

## [1.2.0] - 2025-08-26

### Fixed
- **Critical Submodule Issue**: Fixed worktree creation breaking .claude submodule relationship
  - Replaced content copying with proper `git submodule update --init --recursive`
  - Prevents .claude files from being tracked as regular git files in worktrees
  - Only copies `settings.local.json` to preserve user customizations
  - Maintains proper submodule relationship across all worktrees

- **Script Execute Permissions**: Fixed missing execute permissions causing "permission denied" errors
  - Added execute permission to `protect-local-files.sh`
  - Worktree creation now automatically runs `chmod +x` on all `.claude/scripts/*.sh`
  - Prevents permission errors when running Claude commands in worktrees
  - Fixes issue where git submodule init doesn't preserve execute permissions

### Enhanced
- **PostgreSQL Database Setup**: Made database cloning more robust and compatible
  - Uses environment variables: `PGHOST`, `PGPORT`, `PGUSER` with sensible defaults
  - Falls back to current user, then postgres user for connection attempts
  - Comprehensive error messages with troubleshooting guidance
  - Supports any PostgreSQL version (not hardcoded to @14)
  - Better connection testing and validation

### Added
- **File Protection System**: Comprehensive deny rules to protect critical files
  - Prevents modification of .claude submodule files (except settings.local.json)
  - Protects .env files from deletion or overwriting
  - Added to `settings.local.json.example` with Claude Code permission patterns
  - Includes documentation about protection limitations due to Claude Code bugs

- **Seamless Feature Documentation**: Converted `/cmd-feature-document` to use script execution
  - Added `scripts/feature-document.sh` with full documentation workflow
  - Added script permissions to `settings.local.json.example`
  - Eliminates need for bash command approvals during documentation

### Updated
- **Submodule Conversion Process**: Fixed README instructions for existing .claude directories
  - Added proper cleanup of cached git submodule references
  - Enhanced one-liner command with `git submodule deinit` and cache removal
  - Better preservation of `settings.local.json` during conversion
  - More robust error handling and graceful fallbacks

## [1.1.0] - 2025-08-19

### Added
- **Seamless Worktree Creation**: Enhanced Claude Code worktree creation to run without bash command approvals
  - Added comprehensive script execution permissions to `settings.local.json.example`
  - Enhanced `worktree-create.sh` with automatic project root detection
  - Updated `cmd-worktree-create.md` with improved execution instructions
  - Script now works from any directory within the project
  - Eliminates need for repetitive bash command approvals during worktree setup

### Improved
- **Script Path Handling**: Worktree creation script now automatically finds project root and uses absolute paths
- **Execution Context**: Commands work reliably whether run from project root or subdirectories
- **Documentation**: Enhanced command templates with clearer instructions and execution examples

### Technical Details
- Added `find_project_root()` function for robust directory detection
- Updated all file operations to use `$PROJECT_ROOT` variable
- Added multiple permission patterns to handle different execution contexts
- Maintained backward compatibility while improving user experience

---

## Format

Use this format for new entries:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- **Feature Name**: Description of new developer tooling or workflow improvement
  - Sub-feature or detail
  - Another sub-feature

### Fixed
- **Issue Description**: What developer pain point was resolved

### Improved
- **Component Name**: How existing developer tools were enhanced

### Removed
- **Deprecated Feature**: What was removed and why

### Technical Details
- Key implementation notes for developers
- Breaking changes or migration steps
```

### Categories
- **Added**: New developer tools, scripts, or workflow improvements
- **Fixed**: Bug fixes in development tooling or processes
- **Improved**: Enhancements to existing developer experience
- **Removed**: Deprecated tools or processes
- **Technical Details**: Implementation notes, breaking changes, migration steps