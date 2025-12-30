# Write Ticket

## Purpose
Draft a well-structured ticket for Linear based on context and conversation.

## Variables
- `$TICKET_TYPE`: The type of ticket (bug, feature, chore, improvement)
- `$PRIORITY`: urgent | high | medium | low
- `$CONTEXT`: Relevant context from conversation or codebase
- `$TEAM`: Linear team identifier (if known)
- `$BLOCKS`: Tickets this blocks (optional)
- `$BLOCKED_BY`: Tickets this is blocked by (optional)

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

6. **Set Priority**
   - **Urgent**: Production down, security issue, data loss risk
   - **High**: Blocking other work, major user impact, committed deadline
   - **Medium**: Important but not urgent, planned work
   - **Low**: Nice to have, tech debt, future improvements

   Consider:
   - User impact (how many affected? how severe?)
   - Business urgency (deadline? revenue impact?)
   - Dependencies (is this blocking other tickets?)
   - Effort vs value (quick win? high impact?)

7. **Set Dependencies** (if applicable)
   - **Blocks**: What tickets can't start until this is done?
   - **Blocked by**: What must be done before this can start?

   Ask:
   - "Does this need anything else to be done first?"
   - "Will completing this unblock other work?"
   - Link related tickets even if not strict dependencies

8. **Review with User**
   - Present draft for feedback
   - Show suggested labels/team/project/priority
   - Show dependencies if any
   - Iterate if needed

9. **Create in Linear**
   - Use Linear MCP to create issue
   - Apply chosen labels, team, project, priority
   - Set up dependency links (blocks/blocked by)
   - Link to relevant resources

## Output Format
Present the ticket as:

```
## [TICKET_TYPE] Title Here

**Priority:** [urgent/high/medium/low]
**Labels:** [suggested labels]
**Project:** [project name if applicable]
**Blocked by:** [ticket IDs, or "None"]
**Blocks:** [ticket IDs, or "None"]

### Description
[Problem statement or feature goal]

### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

### Context
[Technical context, related code, links]

### Dependencies
[Explain relationships - why this blocks or is blocked by other tickets]

---
Ready to create in Linear? (yes/no/edit)
```

## Priority Quick Reference

| Priority | When to Use | Examples |
|----------|-------------|----------|
| **Urgent** | Drop everything | Prod down, security breach, data loss |
| **High** | This sprint, ASAP | Blocking others, major bug, deadline |
| **Medium** | Planned work | Features, improvements, scheduled |
| **Low** | When time allows | Tech debt, nice-to-have, polish |
