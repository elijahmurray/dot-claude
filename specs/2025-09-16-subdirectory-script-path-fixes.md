# subdirectory-script-path-fixes Feature Specification

**Date**: 2025-09-16
**Feature**: subdirectory-script-path-fixes
**Status**: Completed

## Overview

Fixed notification script failures when working in subdirectories by implementing robust path resolution that automatically finds scripts from any directory depth, eliminating the need for manual `--add-dir` configuration in most cases.

## User Requirements

- Fix error: `.claude/scripts/notify-agent-complete.sh: No such file or directory` when working in subdirectories
- Make script execution work automatically from any project subdirectory
- Preserve the `--add-dir` option for users who prefer explicit configuration
- Provide universal solution for any script in the .claude template

## Technical Specifications

### Implementation Details
- Created universal script wrapper with project root detection
- Enhanced notification hooks with directory search patterns
- Added self-location detection to notification script
- Implemented fallback search in both `.claude/scripts/` and `scripts/` directories

### Files Modified/Created
- `scripts/find-and-run.sh` - New universal script wrapper
- `settings.local.json.example` - Updated hooks with search patterns and bash -c permission
- `scripts/notify-agent-complete.sh` - Added self-location detection variables
- `README.md` - Enhanced subdirectory documentation with multiple approaches
- `CLAUDE.md` - Comprehensive subdirectory working guidance

### Key Decisions Made
- Used bash search loops in hooks for maximum compatibility
- Implemented up to 5-level directory searching (covers most project structures)
- Preserved existing `--add-dir` workflow as alternative approach
- Added universal wrapper that works for any script execution
- Made all solutions work without requiring user configuration changes

## Testing Requirements

- Test notification hooks from various subdirectory depths
- Verify find-and-run wrapper functionality
- Confirm scripts work in both project types (using .claude and dot-claude repo)
- Validate `--add-dir` still works as documented

## Dependencies

Standard bash utilities only (no external dependencies added)

## Future Considerations

- Could add configuration file to customize search depth
- Consider adding debug mode for troubleshooting path issues
- Could implement caching for frequently accessed script paths

## Implementation Notes

The solution provides three approaches:
1. **Automatic (default)**: Hooks search directory tree automatically
2. **Manual (`--add-dir`)**: Explicit path configuration for maximum reliability
3. **Wrapper**: `find-and-run.sh` for custom script execution

Search pattern: `. .. ../.. ../../.. ../../../..` covers up to 5 directory levels, which handles most real-world project structures including deeply nested component directories.
