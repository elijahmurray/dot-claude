# PM/Linear Skill

## Purpose
Assist with product management workflows: writing tickets, triaging bugs, updating priorities, and managing work in Linear.

## When to Activate
Activate this skill when the user:
- Asks to write, create, or draft a ticket/issue/story
- Wants to triage or categorize bugs
- Discusses prioritization or backlog management
- References Linear or ticket management
- Asks for help with product specs or requirements

## Prerequisites
- Linear MCP server must be configured
- User should have Linear CLI or MCP access
- Workspace config synced (auto-prompted if missing/stale)

## Workspace Config

This skill uses a local cache of your Linear workspace metadata for accurate suggestions.

**Location:** `.claude/linear-workspace.json`

**Auto-sync behavior:**
- Missing config → prompt to sync on first ticket creation
- Config >7 days old → prompt to refresh
- User says "sync linear" → force refresh
- Label/project not found → suggest refresh

See `cookbook/workspace-config.md` for details.

## Variables
- `$TICKET_TYPE`: bug | feature | chore | improvement
- `$PRIORITY`: urgent | high | medium | low
- `$TEAM`: The Linear team/project identifier
- `$CONTEXT`: Relevant codebase or conversation context

## Workflow

### Before Any Operation
1. Check for `.claude/linear-workspace.json`
2. If missing or stale (>7 days), run `prompts/sync-workspace.md`
3. Load workspace labels, teams, projects, states for suggestions

### For Writing New Tickets
1. Determine ticket type from context (bug, feature, chore)
2. Read `cookbook/ticket-templates.md` for the appropriate template
3. Read `cookbook/pm-style-guide.md` for writing conventions
4. Draft the ticket following the template
5. Suggest labels/project from workspace config (not generic ones)
6. Ask user to review before creating in Linear
7. Use Linear MCP to create the ticket

### For Triaging
1. Read `prompts/triage-bug.md`
2. Gather information about the issue
3. Suggest priority and categorization using workspace labels
4. Optionally create or update ticket

### For Batch Operations
1. Read `prompts/batch-review.md`
2. Query Linear for relevant tickets
3. Provide summary and recommendations

### For Syncing Workspace
1. Read `prompts/sync-workspace.md`
2. Fetch labels, teams, projects, states, members from Linear MCP
3. Save to `.claude/linear-workspace.json`
4. Confirm what was synced

## Cookbook (Progressive Disclosure)
Only read these when relevant:
- User asks about templates → `cookbook/ticket-templates.md`
- User asks about style → `cookbook/pm-style-guide.md`
- User asks about Linear specifics → `cookbook/linear-patterns.md`
- User asks about workspace config → `cookbook/workspace-config.md`

## Integration
This skill composes with the Linear MCP server. Ensure MCP is configured:

**Claude Code CLI:**
```bash
claude mcp add --transport http linear https://mcp.linear.app/mcp
```

**Or add to settings.local.json:**
```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.linear.app/mcp"]
    }
  }
}
```

Authentication uses OAuth 2.1 - you'll be prompted to authorize on first use.
To clear cached auth: `rm -rf ~/.mcp-auth`

## Examples
- "write a ticket for the auth bug we discussed" → activates write-ticket with bug template
- "help me triage these 5 issues" → activates batch-review
- "create a feature ticket for dark mode" → activates write-ticket with feature template
- "what's the priority for this?" → activates triage workflow
- "sync linear workspace" → refreshes workspace config
- "refresh linear labels" → triggers workspace sync
