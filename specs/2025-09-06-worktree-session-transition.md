# worktree-session-transition Feature Specification

**Date**: 2025-09-06  
**Feature**: worktree-session-transition  
**Status**: Implemented  

## Overview

Enhanced the worktree creation workflow to ensure users properly transition their Claude Code session to the newly created worktree directory. This prevents accidental modifications to wrong worktrees and ensures all work happens in the isolated environment with the correct database and dependencies.

## User Requirements

The user identified a critical workflow issue: after creating a worktree, users need to:
1. End their current Claude session
2. CD into the new worktree directory (`trees/BRANCH_NAME`)  
3. Start a new Claude session in that directory

Without clear guidance, users might continue working in the wrong directory, defeating the purpose of worktree isolation. The user wanted prominent visual indicators, terminal automation, and clear instructions to ensure proper session transition.

## Technical Specifications

### Implementation Details

The solution implements a multi-layered approach to guide users through the session transition:

1. **Visual Instructions Layer**: Eye-catching, impossible-to-miss instructions
2. **Terminal Automation Layer**: Automatic new tab creation in Warp Terminal
3. **Notification Layer**: Desktop notifications via existing notification system
4. **Permissions Layer**: Pre-approved commands for seamless automation

### Files Modified/Created

1. **scripts/worktree-create.sh**
   - Added ANSI color variables for visual formatting
   - Implemented prominent bordered instruction box with color-coded steps
   - Added Warp Terminal detection and automation (3 fallback methods)
   - Integrated with existing notification system
   - Clear copy-paste commands for manual execution

2. **settings.local.json.example**
   - Added `Bash(osascript:*)` for AppleScript automation
   - Added `Bash(warp-cli:*)` for Warp CLI automation
   - Added `Bash(terminal-notifier:*)` for enhanced notifications

### Key Decisions Made

1. **Multi-layered Approach**: Rather than relying on a single method, implemented multiple layers of guidance to ensure users don't miss the instructions
2. **Graceful Degradation**: Terminal automation attempts multiple methods and falls back to manual instructions if automation fails
3. **Visual Priority**: Made the instruction box deliberately large and red-bordered to be impossible to ignore
4. **Terminal Detection**: Used `$TERM_PROGRAM` environment variable to detect Warp Terminal
5. **Existing Infrastructure**: Leveraged the existing `notify-agent-complete.sh` system rather than creating new notification logic

## Testing Requirements

1. **Visual Display Testing**
   - Verify ANSI color codes render correctly
   - Ensure instruction box is prominently displayed
   - Test copy-paste commands work as expected

2. **Warp Terminal Automation**
   - Test with warp-cli installed
   - Test AppleScript fallback methods
   - Verify graceful degradation on non-Warp terminals

3. **Notification System**
   - Verify desktop notifications appear
   - Test notification content includes correct worktree path
   - Ensure notifications don't block script execution

4. **Permission System**
   - Confirm no bash approval prompts for automation commands
   - Test all three automation methods run without prompts

## Dependencies

- **Existing**: git, bash, ANSI color support in terminal
- **Optional**: Warp Terminal, warp-cli, terminal-notifier, osascript (macOS)
- **No new required dependencies** - all enhancements are optional/graceful

## Future Considerations

1. **Additional Terminal Support**: Could add automation for iTerm2, Terminal.app, and other popular terminals
2. **Session Persistence**: Could explore ways to automatically transfer Claude session context to new directory
3. **Automation Enhancement**: Could add option to automatically start `claude code` in new tab
4. **Cross-Platform Support**: Current automation is macOS-specific; could add Linux/Windows support

## Implementation Notes

### Visual Instruction Box Structure
```bash
╔══════════════════════════════════════════════════════════════════╗
║  IMPORTANT: SWITCH TO WORKTREE NOW!                             ║
║  Required steps with color-coded instructions                    ║
║  Copy-paste ready commands                                      ║
╚══════════════════════════════════════════════════════════════════╝
```

### Warp Automation Methods (in order)
1. `warp-cli open` with --new-tab and --title flags
2. AppleScript with full navigation and title setting
3. Simple AppleScript tab creation (manual cd required)

### Notification Integration
- Uses "attention" type notification for urgency
- Includes branch name in notification title
- Runs in background with `&` to avoid blocking

### Color Scheme
- **Red**: Border and critical warnings
- **Green**: Action steps
- **Cyan**: Commands to copy
- **Yellow**: Important notes
- **White**: Explanatory text

The implementation ensures that regardless of terminal type or available tools, users will receive clear, prominent instructions on how to properly transition to their new worktree environment.