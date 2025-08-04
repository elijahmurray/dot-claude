# pr-create.md

Create a pull/merge request after ensuring all documentation is complete.

## Variables
- BRANCH_NAME: The feature branch name (optional, defaults to current branch)
- PR_TITLE: Title for the pull request (optional)
- PR_BODY: Body text for the pull request (optional)

## Instructions

This command creates a PR/MR by calling the automated script. No manual prompts required.

```bash
# Call the automated PR creation script
.claude/scripts/pr-create.sh "$BRANCH_NAME" "$PR_TITLE" "$PR_BODY"
```

## Purpose
This command creates a pull request while ensuring:
- Documentation has been completed first
- All changes are pushed to remote
- PR includes proper description and references
- Clear next steps are provided

## Usage Examples
```bash
# Create PR for current branch
/cmd-pr-create

# Create PR with custom title
/cmd-pr-create --title "Add user authentication feature"

# Create PR for specific branch
/cmd-pr-create feature/oauth-integration
```