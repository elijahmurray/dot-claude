# Linear Patterns

## Branch Naming
Linear auto-links branches that include the issue ID:
- `feature/ENG-123-add-dark-mode`
- `fix/ENG-456-login-timeout`
- `chore/ENG-789-update-deps`

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
