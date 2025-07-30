# dot-claude

Reusable Claude AI commands and workflows that can be shared across multiple projects.

## Overview

This repository contains the `.claude` directory that gets included in projects created from the [claude-project-template](https://github.com/elijahmurray/claude-project-template). It maintains its own git repository so that improvements can be shared across all projects using this setup.

## Structure

```
.claude/
├── prompts/                    # Reusable Claude commands
│   ├── refactor.md            # Code refactoring assistance
│   ├── test-suite.md          # Test creation and improvement
│   └── optimize.md            # Performance optimization
├── commands/                   # Git workflow commands
│   ├── cmd-issue-*.md         # Issue management
│   ├── cmd-pr-*.md            # Pull request workflows
│   └── ...
├── scripts/                    # Utility scripts
├── CLAUDE.md                  # Claude context file
├── DEV_EXPERIENCE_CHANGELOG.md # Changelog for .claude improvements
└── settings.local.json.example # Example settings
```

## Using in Your Projects

When you create a new project from claude-project-template:
1. The template includes this .claude directory
2. After running `init-project.sh`, the main project's .git is removed
3. This .claude/.git remains, allowing you to pull updates

## Updating Your Project's .claude

To get the latest improvements:
```bash
cd .claude
git pull origin main
```

## Contributing Improvements

If you create useful commands in your project:

1. Navigate to the .claude directory
2. Commit your changes
3. Push to this repository

```bash
cd .claude
git add prompts/my-new-command.md
git commit -m "Add command for X functionality"
git push origin main
```

## Available Commands

### Development Commands
- `/refactor` - Help refactor code for quality and maintainability
- `/test-suite` - Create or improve test coverage
- `/optimize` - Analyze and optimize performance

### Git Workflow Commands
- `/cmd-issue-start` - Start work on a new issue
- `/cmd-pr-create` - Create a pull request with documentation
- `/cmd-issue-complete` - Complete an issue after merge
- And more...

## Best Practices

1. **Keep commands generic** - They should work across different project types
2. **Document changes** - Update DEV_EXPERIENCE_CHANGELOG.md
3. **Test before pushing** - Ensure commands work in a fresh project
4. **Share improvements** - If it helps you, it might help others

## License

[Add your license here]