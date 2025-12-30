# Linear Patterns

## Branch Naming

**IMPORTANT:** Every branch MUST include the ticket ID for auto-linking.

### Format
```
{type}/{TICKET_ID}-{description}
```

### Types
| Ticket Type | Branch Prefix |
|-------------|---------------|
| Feature | `feature/` |
| Bug | `fix/` |
| Chore | `chore/` |
| Improvement | `chore/` or `feature/` |
| Hotfix (urgent) | `hotfix/` |

### Examples
- `feature/RAI-270-add-user-authentication`
- `fix/RAI-271-login-timeout-error`
- `chore/RAI-272-update-dependencies`
- `hotfix/RAI-273-security-patch`

### Rules
1. **Always include ticket ID** - This is how Linear auto-links
2. **Lowercase with hyphens** - No spaces, underscores, or caps
3. **Keep description short** - 3-5 words max
4. **Match type to ticket** - Bug tickets get `fix/`, features get `feature/`

### What Linear Auto-Links
When your branch contains `RAI-270` (or your team's prefix):
- Branch appears on the ticket in Linear
- Commits to that branch are linked
- PRs from that branch are linked
- Merging can auto-close the ticket

## Commit Messages
Include issue ID to auto-link:
- `ENG-123: Add dark mode toggle`
- `Fix ENG-456: Handle timeout on slow connections`

## PR Descriptions
Reference issues to auto-close:
- `Closes ENG-123`
- `Fixes ENG-456`

## Workflow States
Typical Linear workflow:
1. **Backlog** - Triaged but not planned
2. **Todo** - Planned for current cycle
3. **In Progress** - Actively being worked on
4. **In Review** - PR open, awaiting review
5. **Done** - Merged and deployed

## Cycles
- Use cycles for sprint planning
- Move incomplete work to next cycle, don't delete
- Review cycle velocity for planning

## Projects vs Teams
- **Teams**: Permanent groups (Engineering, Design)
- **Projects**: Temporary initiatives (Q1 Launch, Migration)

## Useful Filters
Save these as views:
- My open issues: `assignee:me state:todo,inProgress`
- Bugs to triage: `label:bug state:backlog -priority:*`
- Stale issues: `updated:<-30d state:todo,inProgress`
