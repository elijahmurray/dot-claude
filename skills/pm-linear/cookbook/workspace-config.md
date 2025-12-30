# Workspace Config

The pm-linear skill uses a local config file to know your Linear workspace's labels, projects, teams, and workflow states.

## Config Location

```
.claude/linear-workspace.json
```

This file is per-project and should be gitignored (it contains workspace-specific data).

## Auto-Sync Behavior

| Trigger | Action |
|---------|--------|
| Config missing | Prompt to sync on first ticket creation |
| Config >7 days old | Auto-prompt to refresh |
| User says "sync linear" | Force refresh |
| Label/project not found | Suggest refresh |

## Config Structure

```json
{
  "lastSynced": "2025-12-30T10:00:00Z",
  "syncIntervalDays": 7,
  "workspace": {
    "name": "My Company",
    "teams": [...],
    "labels": [...],
    "states": [...],
    "projects": [...],
    "members": [...]
  }
}
```

### Teams
```json
{
  "id": "abc123",
  "name": "Engineering",
  "key": "ENG"
}
```
The `key` is used for issue prefixes (e.g., ENG-123).

### Labels
```json
{
  "id": "def456",
  "name": "bug",
  "color": "#eb5757",
  "team": "Engineering"
}
```
Labels can be workspace-wide or team-specific.

### Workflow States
```json
{
  "id": "ghi789",
  "name": "In Progress",
  "type": "started",
  "team": "Engineering"
}
```
Types: `backlog`, `unstarted`, `started`, `completed`, `canceled`

### Projects
```json
{
  "id": "jkl012",
  "name": "Q1 Launch",
  "state": "started",
  "team": "Engineering"
}
```
Only active/started projects are synced by default.

### Members
```json
{
  "id": "mno345",
  "name": "Jane Doe",
  "email": "jane@example.com"
}
```
Used for assignment suggestions.

## Manual Configuration

If you prefer not to use auto-sync, create the config manually:

```bash
# Create the config file
cat > .claude/linear-workspace.json << 'EOF'
{
  "lastSynced": "2025-12-30T00:00:00Z",
  "syncIntervalDays": 9999,
  "workspace": {
    "name": "My Workspace",
    "teams": [
      {"id": "team1", "name": "Engineering", "key": "ENG"}
    ],
    "labels": [
      {"id": "l1", "name": "bug", "color": "#eb5757", "team": "Engineering"},
      {"id": "l2", "name": "feature", "color": "#5e6ad2", "team": "Engineering"},
      {"id": "l3", "name": "improvement", "color": "#26b5ce", "team": "Engineering"},
      {"id": "l4", "name": "chore", "color": "#95a2b3", "team": "Engineering"}
    ],
    "states": [
      {"id": "s1", "name": "Backlog", "type": "backlog", "team": "Engineering"},
      {"id": "s2", "name": "Todo", "type": "unstarted", "team": "Engineering"},
      {"id": "s3", "name": "In Progress", "type": "started", "team": "Engineering"},
      {"id": "s4", "name": "Done", "type": "completed", "team": "Engineering"}
    ],
    "projects": [],
    "members": []
  }
}
EOF
```

Set `syncIntervalDays` to a high number (like 9999) to disable auto-sync prompts.

## Gitignore

Add to your `.gitignore`:
```
.claude/linear-workspace.json
```

This file contains workspace-specific data that shouldn't be shared across team members (they'll have their own sync).

## Customizing Sync Interval

Edit the config to change how often you're prompted to refresh:

```json
{
  "syncIntervalDays": 14
}
```

Set to `7` for weekly (default), `30` for monthly, or `9999` to disable.

## Troubleshooting

**"Config is stale" keeps appearing:**
- Run sync to refresh, or increase `syncIntervalDays`

**Labels don't match Linear:**
- Run "sync linear workspace" to refresh
- Check if labels are team-specific vs workspace-wide

**Missing teams/projects:**
- Ensure your Linear API token has access to those resources
- Re-authenticate: `rm -rf ~/.mcp-auth` and try again
