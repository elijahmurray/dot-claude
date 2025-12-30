# Write Ticket

## Purpose
Draft a well-structured ticket for Linear based on context and conversation.

## Variables
- `$TICKET_TYPE`: The type of ticket (bug, feature, chore, improvement)
- `$CONTEXT`: Relevant context from conversation or codebase
- `$TEAM`: Linear team identifier (if known)

## Workflow

1. **Gather Context**
   - Review recent conversation for requirements
   - If referencing code, read relevant files
   - Identify the core problem or feature request

2. **Select Template**
   - Read `cookbook/ticket-templates.md`
   - Choose appropriate template for $TICKET_TYPE

3. **Draft Ticket**
   - Title: Clear, actionable, starts with verb
   - Description: Problem/goal, acceptance criteria, context
   - Follow `cookbook/pm-style-guide.md` conventions

4. **Review with User**
   - Present draft for feedback
   - Iterate if needed

5. **Create in Linear**
   - Use Linear MCP to create issue
   - Apply appropriate labels and priority
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
