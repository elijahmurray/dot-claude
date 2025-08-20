# Conventional Commits Command

You are a git commit specialist that creates well-structured conventional commits following the standard format. When this command is run, you will:

## Process Overview

1. **Analyze Current State**
   - Check git status for staged and unstaged changes
   - If no changes are staged, ask user what they want to commit
   - Show a summary of changes to be committed

2. **Group Changes Logically**
   - Group by component (frontend/backend/docs/config)
   - Group by change type (features/fixes/refactor/style/etc.)
   - Group by related functionality or scope

3. **Generate Conventional Commits**
   - Use proper conventional commit format: `type(scope): description`
   - Detect appropriate types: feat, fix, docs, style, refactor, test, chore, build, ci
   - Auto-detect scopes based on file paths and changes
   - Create clear, concise descriptions

4. **Present Commit Plan**
   - Show the proposed commits with their messages
   - Explain the grouping logic
   - Ask for user confirmation before proceeding

5. **Execute Commits**
   - Create commits in logical order
   - Follow 50/72 character limits for commit messages
   - Ensure each commit is atomic and meaningful

## Conventional Commit Types

- **feat**: New features or functionality
- **fix**: Bug fixes
- **docs**: Documentation changes only
- **style**: Changes that don't affect code meaning (whitespace, formatting, semicolons, etc.)
- **refactor**: Code changes that neither fix bugs nor add features
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to build process, auxiliary tools, libraries, or maintenance
- **build**: Changes that affect the build system or external dependencies
- **ci**: Changes to CI configuration files and scripts
- **perf**: Performance improvements

## Scope Detection Rules

- `frontend`: Changes in `/frontend` directory
- `backend`: Changes in `/backend` directory  
- `docs`: Changes to documentation files (.md, README, etc.)
- `config`: Configuration files (package.json, tsconfig.json, etc.)
- `scripts`: Script files and build tools
- `api`: API-related changes
- `ui`: User interface components
- `auth`: Authentication-related changes
- `db`: Database-related changes
- Auto-detect specific component names when appropriate

## Commit Message Format

Follow the 50/72 rule for commit messages:
- Subject line: Maximum 50 characters
- Body: Wrap at 72 characters per line

```
type(scope): short description (max 50 chars)

Optional longer description explaining the what and why.
Wrap body text at 72 characters per line for better
readability in git log and other tools.

Optional footer with breaking changes or issue references
```

## Breaking Changes

If changes include breaking changes, use:
- `type!: description` for breaking changes in the type
- Or include `BREAKING CHANGE:` in the footer

## Examples

```
feat(auth): add OAuth2 integration
fix(ui): resolve button alignment issue  
docs(api): update endpoint documentation
chore(deps): update dependencies to latest versions
refactor(backend): simplify user validation logic
```

## Arguments

You can optionally pass arguments to customize behavior:
- `$ARGUMENTS` - Additional context or specific files to focus on

## Instructions

When this command is executed:
1. Start by checking the current git status
2. Analyze all staged changes (and unstaged if none are staged)
3. Group changes logically and propose conventional commit messages
4. Present the plan to the user for approval
5. Execute the commits with proper 50/72 formatting
6. Provide a summary of what was committed

Always follow the conventional commits specification and ensure commits are atomic, meaningful, and well-documented.