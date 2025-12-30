# Write Ticket

## Purpose
Draft a well-structured ticket for Linear based on context and conversation.

## Variables
- `$TICKET_TYPE`: The type of ticket (bug, feature, chore, improvement)
- `$CONTEXT`: Relevant context from conversation or codebase
- `$TEAM`: Linear team identifier (if known)

## Workflow

1. **Check Workspace Config**
   - Look for `.claude/linear-workspace.json`
   - If missing or >7 days old, run `prompts/sync-workspace.md` first
   - Load available labels, teams, projects for suggestions

2. **Gather Context**
   - Review recent conversation for requirements
   - If referencing code, read relevant files
   - Identify the core problem or feature request

3. **Select Template**
   - Read `cookbook/ticket-templates.md`
   - Choose appropriate template for $TICKET_TYPE

4. **Draft Ticket**
   - Title: Clear, actionable, starts with verb
   - Description: Problem/goal, acceptance criteria, context
   - Follow `cookbook/pm-style-guide.md` conventions

5. **Suggest Labels & Project**
   - Use labels from workspace config (not generic ones)
   - Suggest appropriate team based on context
   - Recommend project if one fits

6. **Review with User**
   - Present draft for feedback
   - Show suggested labels/team/project
   - Iterate if needed

7. **Create in Linear**
   - Use Linear MCP to create issue
   - Apply chosen labels, team, project, priority
   - Link to relevant resources

## Output Format
Present the ticket as:

```
## [TICKET_TYPE] Title Here

**Priority:** [suggested priority]
**Labels:** [suggested labels]

### Description
[Problem statement or feature goal]

### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

### Context
[Technical context, related code, links]

---
Ready to create in Linear? (yes/no/edit)
```
