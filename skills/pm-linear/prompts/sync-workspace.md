# Sync Workspace

## Purpose
Fetch and cache Linear workspace metadata (labels, projects, teams, states) for accurate ticket suggestions.

## When to Run
- **Automatically**: When workspace config is missing or older than 7 days
- **Manually**: When user asks to "refresh linear config" or "sync linear workspace"
- **On error**: If a suggested label/project doesn't exist

## Workflow

1. **Check Existing Config**
   ```
   Look for: .claude/linear-workspace.json
   If exists, check lastSynced timestamp
   If < 7 days old and not forced refresh, skip sync
   ```

2. **Fetch from Linear MCP**
   Use Linear MCP to query:
   - `linear_teams` - Get all teams
   - `linear_labels` - Get all labels (per team)
   - `linear_workflow_states` - Get workflow states
   - `linear_projects` - Get active projects
   - `linear_users` - Get team members (for assignment)

3. **Build Config**
   Structure the data for easy lookup:
   ```json
   {
     "lastSynced": "2025-12-30T10:00:00Z",
     "syncIntervalDays": 7,
     "workspace": {
       "name": "Workspace Name",
       "teams": [
         {
           "id": "team-id",
           "name": "Engineering",
           "key": "ENG"
         }
       ],
       "labels": [
         {
           "id": "label-id",
           "name": "bug",
           "color": "#eb5757",
           "team": "Engineering"
         }
       ],
       "states": [
         {
           "id": "state-id",
           "name": "In Progress",
           "type": "started",
           "team": "Engineering"
         }
       ],
       "projects": [
         {
           "id": "project-id",
           "name": "Q1 Launch",
           "state": "started",
           "team": "Engineering"
         }
       ],
       "members": [
         {
           "id": "user-id",
           "name": "Jane Doe",
           "email": "jane@example.com"
         }
       ]
     }
   }
   ```

4. **Save Config**
   Write to `.claude/linear-workspace.json`
   Ensure `.claude/linear-workspace.json` is in `.gitignore`

5. **Confirm**
   Report what was synced:
   ```
   ✅ Linear workspace synced
   - 2 teams: Engineering, Design
   - 15 labels
   - 8 workflow states
   - 3 active projects
   - 12 team members

   Config saved to .claude/linear-workspace.json
   Next auto-sync: 2025-01-06
   ```

## Stale Config Handling

When config is stale (>7 days), prompt user:
```
Your Linear workspace config is X days old.
Sync now to get latest labels and projects? (yes/no/skip)
```

If user says skip, continue with existing config but note it may be outdated.

## Error Handling

**MCP not configured:**
```
Linear MCP server not found. Set it up first:
claude mcp add --transport http linear https://mcp.linear.app/mcp
```

**Auth expired:**
```
Linear authentication expired. Re-authenticate:
rm -rf ~/.mcp-auth
Then try again - you'll be prompted to log in.
```

**Partial failure:**
If some queries fail, save what we got and note incomplete sync.
