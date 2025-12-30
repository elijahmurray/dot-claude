# PM Style Guide

## Ticket Titles
- Start with a verb: "Add", "Fix", "Update", "Remove", "Implement"
- Be specific: "Fix login timeout on slow connections" not "Fix login"
- Keep under 60 characters when possible
- No periods at the end

## Descriptions
- Lead with the "why" - what problem are we solving?
- Use bullet points for lists
- Include acceptance criteria as checkboxes
- Link to related tickets, docs, or designs
- Add technical context for engineering

## Priority Guidelines
- **Urgent**: Drop everything. Production down, security issue, data loss.
- **High**: Do this sprint. Major user impact, blocking other work.
- **Medium**: Plan for soon. Important but not urgent.
- **Low**: Nice to have. Do when capacity allows.

## Labels
Use consistent labels:
- `bug`, `feature`, `chore`, `improvement`
- `frontend`, `backend`, `infrastructure`, `mobile`
- `needs-design`, `needs-review`, `blocked`

## Writing Tips
- Write for the person who will implement this (often future you)
- Assume context will be lost - be explicit
- Include "why" not just "what"
- Add reproduction steps for bugs (every time)
- Define "done" clearly
