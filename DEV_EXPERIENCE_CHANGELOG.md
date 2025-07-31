# .claude Developer Experience Changelog

All notable changes to the .claude directory commands and workflows will be documented in this file.

This changelog tracks improvements to the reusable Claude commands that can be pulled into any project using this boilerplate.

## [Unreleased]

### Added
- Initial set of reusable Claude prompts
  - `/refactor` - Code refactoring assistance
  - `/test-suite` - Test creation and improvement
  - `/optimize` - Performance optimization
- Git workflow commands from original boilerplate
- Notification system for long-running tasks
- **Git Submodule Support**: Complete workflow for using dot-claude as a git submodule
  - `scripts/setup-as-submodule.sh` - Helper script to add dot-claude as a submodule
  - `/cmd-claude-update` - Command to update the .claude submodule to latest version
  - Comprehensive documentation for submodule workflows
  - Troubleshooting guide for common submodule issues

### Changed
- **Documentation**: Updated README.md and CLAUDE.md to explain submodule approach
  - Added installation methods (submodule vs direct clone)
  - Included version management guidelines
  - Enhanced contribution instructions for submodule users

### Fixed
- **Worktree Creation**: Now properly copies `.claude` directory including `settings.local.json` into new worktrees
  - Ensures Claude Code has access to all custom commands and settings in worktree environments
  - Added check and warning for missing `settings.local.json` file

### Removed
- None yet

## Update Instructions

When you improve these commands:
1. Make changes in your project's .claude directory
2. Test thoroughly
3. Commit with descriptive message
4. Push to the claude-commands repository
5. Other projects can pull updates with: `cd .claude && git pull origin main`