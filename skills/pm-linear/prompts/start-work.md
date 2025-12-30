# Start Work

## Purpose
Create a ticket-linked branch and set up the development environment. Ensures every branch is associated with a Linear ticket for traceability.

## When to Use
- User wants to start working on something new
- User says "let's implement X" or "start working on Y"
- After creating a ticket: offer to create the branch
- User wants to create a branch for an existing ticket

## Variables
- `$TICKET_ID`: Linear ticket ID (e.g., RAI-270)
- `$TICKET_TITLE`: Title of the ticket
- `$BRANCH_TYPE`: feature | fix | chore | hotfix (default: feature)

## Branch Naming Convention

**Format:** `{type}/{TICKET_ID}-{slug}`

**Examples:**
- `feature/RAI-270-add-user-authentication`
- `fix/RAI-271-login-timeout-error`
- `chore/RAI-272-update-dependencies`
- `hotfix/RAI-273-security-patch`

**Rules:**
- Always include ticket ID for auto-linking
- Use lowercase with hyphens
- Keep slug short but descriptive (3-5 words)
- Match type to ticket type (bug → fix, feature → feature, etc.)

## Workflow

### Starting Fresh (No Ticket Yet)

1. **Create Ticket First**
   - Run `prompts/write-ticket.md` workflow
   - Get the ticket ID from Linear

2. **Generate Branch Name**
   - Determine type from ticket type:
     - Bug → `fix/`
     - Feature → `feature/`
     - Chore/Improvement → `chore/`
   - Slugify the ticket title
   - Format: `{type}/{TICKET_ID}-{slug}`

3. **Create Branch**
   - If using worktrees: `/cmd-worktree-create {type} {TICKET_ID}-{slug}`
   - If simple branch: `git checkout -b {branch_name}`

4. **Confirm Setup**
   ```
   ✅ Ready to start work!

   Ticket: RAI-270 - Add user authentication
   Branch: feature/RAI-270-add-user-authentication

   Linear will auto-link commits and PRs containing "RAI-270".

   Next steps:
   1. Write tests for the feature
   2. Implement to make tests pass
   3. Commit with message: "RAI-270: description"
   ```

### Starting from Existing Ticket

1. **Get Ticket Details**
   - Query Linear MCP for ticket by ID
   - Get title and type

2. **Generate Branch Name**
   - Same format as above

3. **Check if Branch Exists**
   - If exists, offer to check it out
   - If not, create it

4. **Link and Confirm**
   - Same confirmation as above

### Starting from Branch Name

If user provides a branch name without ticket:

1. **Check for Ticket ID**
   - Parse branch name for pattern like `RAI-###`
   - If found, verify ticket exists in Linear

2. **If No Ticket ID**
   - Warn: "This branch isn't linked to a ticket"
   - Offer to create a ticket and rename branch
   - Or proceed with warning

## Slugify Rules

Convert ticket title to branch slug:
1. Lowercase everything
2. Replace spaces with hyphens
3. Remove special characters
4. Truncate to ~50 chars
5. Remove trailing hyphens

**Example:**
- "Add User Authentication with OAuth2" → `add-user-authentication-with-oauth2`
- "Fix: Login timeout on slow connections!" → `fix-login-timeout-on-slow-connections`

## Integration with Worktrees

If project uses worktrees (check for `trees/` directory or ask):

```bash
# Recommended: Use worktree for isolation
.claude/scripts/worktree-create.sh feature RAI-270-add-user-auth

# This creates:
# - trees/RAI-270-add-user-auth/
# - Copies environment files
# - Sets up dependencies
# - Clones database (if PostgreSQL)
```

If not using worktrees:
```bash
git checkout -b feature/RAI-270-add-user-auth
```

## Commit Message Format

Once working, commits should reference the ticket:

```
RAI-270: Add login form component

- Create LoginForm with email/password fields
- Add form validation
- Connect to auth API
```

This auto-links the commit to the Linear ticket.

## Examples

**User:** "let's start working on the auth feature"
1. Check if ticket exists → No
2. Create ticket via write-ticket workflow → RAI-270
3. Generate branch: `feature/RAI-270-add-auth-feature`
4. Create worktree or branch
5. Confirm ready to work

**User:** "start work on RAI-270"
1. Query Linear for RAI-270 → "Add user authentication"
2. Generate branch: `feature/RAI-270-add-user-authentication`
3. Create worktree or branch
4. Confirm ready to work

**User:** "create a branch for the login bug"
1. Check if ticket exists → No
2. Create bug ticket → RAI-271
3. Generate branch: `fix/RAI-271-login-bug`
4. Create and confirm
