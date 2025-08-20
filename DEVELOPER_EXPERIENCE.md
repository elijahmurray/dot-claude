# Developer Experience Changelog

This file tracks improvements to the development workflow, tooling, and developer experience for projects using the dot-claude template.

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