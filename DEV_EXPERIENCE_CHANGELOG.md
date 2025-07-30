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

### Changed
- None yet

### Fixed
- None yet

### Removed
- None yet

## Update Instructions

When you improve these commands:
1. Make changes in your project's .claude directory
2. Test thoroughly
3. Commit with descriptive message
4. Push to the claude-commands repository
5. Other projects can pull updates with: `cd .claude && git pull origin main`