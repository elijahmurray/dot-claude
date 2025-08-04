# Linear MCP Integration Enhancement

**Date:** 2025-08-04  
**Feature:** Linear MCP Integration and Installation Process Improvement

## Overview

Enhanced the MCP installation command to include Linear as a pre-configured option and clarified the user interface for MCP selection during installation.

## User Requirements

- Add Linear as one of the optional MCPs available for installation
- Clarify the MCP installation process - spacebar should toggle selection, not advance
- Provide ready-to-use Linear MCP configuration

## Technical Specifications

### Files Modified
- `commands/cmd-mcp-install.md` - Enhanced with Linear MCP option and UI clarification

### Implementation Details

1. **Linear MCP Configuration**
   - Command: `npx -y mcp-remote https://mcp.linear.app/sse`
   - Configuration type: stdio
   - Installation method: Via npx (no local installation required)

2. **UI Clarification**
   - Added explicit navigation instructions: "Use **spacebar** to toggle selection, **Enter** to proceed with selected options"
   - This resolves user confusion where spacebar was advancing instead of toggling

3. **Pre-configured Options**
   - Added Linear to the list of popular MCP servers
   - Provided ready-to-use command templates for both Linear and Git MCPs

## Key Decisions Made

- **Remote MCP Approach**: Linear uses a remote MCP server (https://mcp.linear.app/sse) rather than local installation
- **NPX Usage**: Leverages npx for zero-installation deployment of the Linear MCP client
- **Documentation Structure**: Added both quick-install options and detailed custom installation steps

## Files Modified/Created

### Modified
- `commands/cmd-mcp-install.md`:
  - Added Linear MCP to popular servers list
  - Added navigation instructions (spacebar/Enter clarification)
  - Added pre-configured server commands section
  - Enhanced structure with quick install options

## Testing Requirements

- Test MCP installation flow with spacebar toggling
- Verify Linear MCP connection works with provided configuration
- Test that Enter key advances after selection, not spacebar

## Dependencies

- Linear MCP requires internet connection to https://mcp.linear.app/sse
- npx (comes with Node.js)
- Claude Code CLI with MCP support

## Future Considerations

- Could add more popular MCP servers (GitHub, Filesystem, SQLite, PostgreSQL) with pre-configured options
- Consider adding environment variable configuration for Linear API tokens
- Could enhance UI with checkbox-style selection indicators

## Implementation Notes

The Linear MCP uses a remote server approach, which means:
- No local installation or build process required
- Connection may require multiple attempts (as noted in Linear docs)
- Uses Server-Sent Events (SSE) endpoint
- Fallback HTTP endpoint available at https://mcp.linear.app/mcp

## Linear MCP Features

Based on Linear documentation, the MCP provides:
- Integration with Linear project management
- Access to Linear issues, projects, and teams
- Real-time updates via SSE connection
- Support for various Claude-compatible IDEs (VSCode, Windsurf, Zed)