# Feature Specification: Worktree .claude Settings Copy

## Overview
Added functionality to copy the `.claude` directory (including `settings.local.json`) when creating a new git worktree, ensuring Claude Code has access to all custom commands and settings in the worktree environment.

## User Requirements
- When creating a worktree using the `cmd-worktree-create.md` command, the `.claude/settings` directory needs to be copied into the worktree
- This is a template project that gets cloned into other projects, and those projects need their `settings.local.json` copied when creating worktrees

## Technical Specifications
- Modified `commands/cmd-worktree-create.md` to include `.claude` directory copying logic
- Added check for `settings.local.json` existence with appropriate warning if not found
- Maintained existing copy operations for other configuration files

## Files Modified/Created
- `/Users/elijahmurray/Development/Vandra/dot-claude/commands/cmd-worktree-create.md` - Added `.claude` directory copy logic

## Key Decisions Made
1. Copy the entire `.claude` directory rather than just `settings.local.json` to ensure all custom commands and configurations are available
2. Added specific check and warning for missing `settings.local.json` to help users understand if they need to create one
3. Placed the `.claude` copy operation before CLAUDE.md copies to maintain logical grouping of Claude-related operations

## Testing Requirements
- Verify that `.claude` directory is properly copied when creating a new worktree
- Ensure `settings.local.json` is copied if it exists
- Confirm appropriate warning message appears if `settings.local.json` doesn't exist

## Dependencies
- No new dependencies added
- Relies on existing shell commands (`cp -r`)

## Future Considerations
- Could add validation to ensure the copied settings are valid JSON
- Might want to merge settings rather than overwrite if worktree-specific settings are needed

## Implementation Notes
- The copy operation uses `cp -r` to recursively copy the entire `.claude` directory
- The path uses `../../.claude` assuming the worktree is created in a `trees/` subdirectory
- Added informative echo statements to provide user feedback during the copy process