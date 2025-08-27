# feature-document.md

Document the feature by creating a specification and updating all relevant documentation files.

## Variables
- FEATURE_NAME: The name of the feature being documented (defaults to current branch name)

## Instructions

Run the automated feature documentation script. The script will automatically detect the correct path regardless of your current directory:

```bash
# From project root
.claude/scripts/feature-document.sh ${FEATURE_NAME}

# From any subdirectory
../scripts/feature-document.sh ${FEATURE_NAME}

# Or let the script find itself
scripts/feature-document.sh ${FEATURE_NAME}
```

The script is pre-approved in settings.local.json and will run without bash command approvals.

## What the Script Does

The feature documentation script handles all documentation workflows automatically:

1. **Determines Feature Name**: Uses current branch name or provided parameter
2. **Creates Feature Specification**: Generates template in `specs/` directory with:
   - Overview and user requirements
   - Technical specifications and implementation details
   - Files modified/created and key decisions
   - Testing requirements and dependencies
   - Future considerations and implementation notes

3. **Analyzes Changes**: Determines if changes are developer-focused or user-facing
4. **Provides Changelog Template**: Shows entry format for appropriate changelog file
5. **Reviews Documentation Needs**: Checks if README.md and CLAUDE.md need updates
6. **Commits Documentation**: Stages and commits all documentation changes
7. **Shows Summary**: Provides next steps for PR creation

## Manual Steps Required

After the script runs, you'll need to:

1. **Complete the specification**: Fill in the generated template with actual details
2. **Add changelog entry**: Copy the provided template to the appropriate changelog
3. **Update README.md**: If the script identifies changes that need documentation
4. **Update CLAUDE.md**: If new development patterns or commands were added

**IMPORTANT**: This command operates in the current working directory. When working in a worktree, it will create documentation within that worktree, not in the parent repository.

## Purpose
This command ensures comprehensive documentation is created BEFORE the PR, so that:
- The PR includes all documentation changes
- Nothing is forgotten or done as an afterthought
- Feature specifications are captured while context is fresh
- Documentation is part of the development process, not a separate task

## Usage Examples
```bash
# Document current feature branch
/cmd-feature-document

# Document with specific feature name
/cmd-feature-document user-authentication

# After completing development work
/cmd-feature-document google-calendar-integration
```