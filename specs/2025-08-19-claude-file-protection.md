# Feature Specification: Claude Code Native File Protection

## Overview
Implemented Claude Code's native file protection system to prevent accidental deletion of `settings.local.json` while still allowing users to edit and customize their settings.

## User Requirements
- Prevent `settings.local.json` from being accidentally deleted by Claude Code commands
- Still allow users to edit and modify their settings as needed
- Use Claude Code's built-in protection mechanisms instead of git-based workarounds
- Ensure protection works in submodule environments

## Technical Specifications

### Claude Code Permissions System
Used Claude Code's native `permissions.deny` configuration to block specific deletion commands:

```json
{
  "permissions": {
    "deny": [
      "Bash(rm *settings.local.json*)",
      "Bash(rm .claude/settings.local.json)",
      "Bash(git rm *settings.local.json*)"
    ]
  }
}
```

### Protection Scope
- **Prevents**: File deletion via `rm`, `git rm`, or wildcard deletion commands
- **Allows**: Writing, editing, and modifying the file via `Write`, `Edit`, `MultiEdit` tools
- **Maintains**: User ability to customize settings while preventing accidental loss

### Implementation Method
- Added denial rules to `settings.local.json.example` template
- Updated setup script to inform users about the protection
- Enhanced .gitignore comments to explain the protection mechanism

## Files Modified/Created

### Modified Files
- `settings.local.json.example` - Added permissions.deny rules for file protection
- `scripts/setup-as-submodule.sh` - Updated messaging about file protection
- `.gitignore` - Enhanced comments to explain Claude Code protection

### Removed Files
- `scripts/protect-local-files.sh` - Removed git-based protection in favor of native Claude Code method

## Key Decisions Made

1. **Native Over Custom**: Used Claude Code's built-in permission system instead of git-based protection
2. **Selective Protection**: Only blocked deletion commands, not editing/writing
3. **Multiple Command Patterns**: Protected against various deletion command formats
4. **User Education**: Added clear messaging about why and how the protection works

## Testing Requirements
- Verify that `rm .claude/settings.local.json` is blocked
- Confirm that editing the file still works normally
- Test that wildcard deletion patterns are prevented
- Ensure protection works in both regular and submodule setups

## Dependencies
- Claude Code's permissions system
- No additional tools or scripts required

## Future Considerations
- Could extend protection to other critical files
- Might add protection against accidental overwrites of important sections
- Could implement warnings before dangerous operations

## Implementation Notes

### Permission Rule Design
The permission rules target specific command patterns that could delete the settings file:
- Direct deletion: `rm .claude/settings.local.json`
- Wildcard deletion: `rm *settings.local.json*`
- Git deletion: `git rm *settings.local.json*`

### User Experience
- Users can still edit their settings normally
- Clear messaging explains the protection during setup
- Protection is automatic and doesn't require user intervention

### Submodule Compatibility
- Works seamlessly with submodule setups
- Protection travels with the template when copied to new projects
- No additional configuration needed in parent repositories

## Usage Workflow

1. **Setup**: Protection is automatically included in `settings.local.json.example`
2. **Customization**: Users can freely edit their settings file
3. **Protection**: Deletion attempts are automatically blocked by Claude Code
4. **Transparency**: Users are informed about the protection during initial setup

This native approach is more reliable than git-based protection and integrates seamlessly with Claude Code's permission system.