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
- **Linear MCP Integration**: Enhanced MCP installation command with Linear support
  - Added Linear as a pre-configured MCP option in `/cmd-mcp-install`
  - Provided ready-to-use Linear MCP configuration using `npx -y mcp-remote https://mcp.linear.app/sse`
  - Clarified MCP installation UI: spacebar toggles selection, Enter proceeds
  - Added pre-configured server commands section with Linear and Git examples

### Changed
- **Documentation**: Updated README.md and CLAUDE.md to explain submodule approach
  - Added installation methods (submodule vs direct clone)
  - Included version management guidelines
  - Enhanced contribution instructions for submodule users
- **cmd-issue-start**: Streamlined for pragmatic, fast development
  - Removed heavy TDD requirements - now focuses on practical testing
  - Emphasizes shipping clean, minimal code quickly
  - Tests for critical paths and features, not everything
  - More real-world approach to development workflow

### Fixed
- **Worktree Creation**: Now properly copies `.claude` directory including `settings.local.json` into new worktrees
  - Ensures Claude Code has access to all custom commands and settings in worktree environments
  - Added check and warning for missing `settings.local.json` file
  - Fixed submodule handling: excludes `.git` file when copying to prevent git errors in worktrees

### Removed
- None yet

## Update Instructions

When you improve these commands:
1. Make changes in your project's .claude directory
2. Test thoroughly
3. Commit with descriptive message
4. Push to the claude-commands repository
5. Other projects can pull updates with: `cd .claude && git pull origin main`