# dot-claude

Reusable Claude AI commands and workflows that can be shared across multiple projects.

## Overview

This repository contains the `.claude` directory that provides a structured workflow for software development with Claude Code. It's designed to be included in projects as a git submodule, allowing you to receive updates while maintaining project-specific customizations.

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
│   ├── cmd-claude-update.md   # Update .claude submodule
│   └── ...
├── scripts/                    # Utility scripts
│   ├── notify-agent-complete.sh
│   └── setup-as-submodule.sh  # Helper to add as submodule
├── CLAUDE.md                  # Claude context file
├── DEV_EXPERIENCE_CHANGELOG.md # Changelog for .claude improvements
└── settings.local.json.example # Example settings
```

## Installation

### Quick Setup (One-Liners)

**For a new project (no existing .claude):**
```bash
cd your-project && bash <(curl -sSL https://raw.githubusercontent.com/elijahmurray/dot-claude/main/scripts/setup-as-submodule.sh)
```

**For a project with existing .claude directory:**
```bash
mv .claude .claude.backup && git submodule add https://github.com/elijahmurray/dot-claude.git .claude && cp .claude.backup/settings.local.json .claude/settings.local.json 2>/dev/null && rm -rf .claude.backup && git add .gitmodules .claude && git commit -m "Convert .claude to submodule"
```

### Method 1: As a Git Submodule (Recommended)

Add dot-claude to your existing project as a submodule:

```bash
# In your project root
git submodule add https://github.com/elijahmurray/dot-claude.git .claude
git commit -m "Add .claude as submodule"

# Create your settings file
cp .claude/settings.local.json.example .claude/settings.local.json
# Edit .claude/settings.local.json with your preferences
```

### Method 2: Direct Clone (Simple Setup)

For projects that don't need update capabilities:

```bash
# Clone directly into your project
git clone https://github.com/elijahmurray/dot-claude.git .claude
rm -rf .claude/.git  # Remove git tracking

# Create your settings file
cp .claude/settings.local.json.example .claude/settings.local.json
```

## Working with Submodules

### For Project Users

When cloning a project that uses dot-claude as a submodule:

```bash
# Clone with submodules included
git clone --recursive https://github.com/user/project.git

# Or if you already cloned without --recursive
git submodule init
git submodule update
```

### Updating dot-claude

To update to the latest version of dot-claude:

```bash
# Method 1: Using the update command
/cmd-claude-update

# Method 2: Manual update
cd .claude
git fetch
git checkout main
git pull
cd ..
git add .claude
git commit -m "Update .claude to latest version"
```

### Pinning to a Specific Version

```bash
cd .claude
git checkout v1.2.3  # or specific commit SHA
cd ..
git add .claude
git commit -m "Pin .claude to version v1.2.3"
```

## Contributing Improvements

When you discover improvements or create new commands:

### From a Submodule Setup

```bash
# Make your changes in .claude
cd .claude
git checkout -b feature/new-command
git add prompts/my-new-command.md
git commit -m "Add command for X functionality"
git push origin feature/new-command

# Create a pull request on GitHub
# After merge, update your project
git checkout main
git pull
cd ..
git add .claude
git commit -m "Update .claude with new command"
```

### Direct Contributions

Fork the repository and submit pull requests with your improvements.

## Available Commands

### Development Commands
- `/refactor` - Help refactor code for quality and maintainability
- `/test-suite` - Create or improve test coverage
- `/optimize` - Analyze and optimize performance

### Git Workflow Commands
- `/cmd-issue-start` - Start work on a new issue
- `/cmd-pr-create` - Create a pull request with documentation
- `/cmd-issue-complete` - Complete an issue after merge
- `/cmd-claude-update` - Update .claude submodule to latest version
- And more...

## Migration Guide

### Converting Existing .claude to Submodule

If your project already has a `.claude` directory from the old clone method:

1. **Backup and convert (one-liner):**
   ```bash
   mv .claude .claude.backup && git submodule add https://github.com/elijahmurray/dot-claude.git .claude && cp .claude.backup/settings.local.json .claude/settings.local.json 2>/dev/null && rm -rf .claude.backup && git add .gitmodules .claude && git commit -m "Convert .claude to submodule"
   ```

2. **Or step-by-step:**
   ```bash
   # Backup existing settings
   cp .claude/settings.local.json settings.backup.json
   
   # Remove old .claude
   rm -rf .claude
   
   # Add as submodule
   git submodule add https://github.com/elijahmurray/dot-claude.git .claude
   
   # Restore settings
   cp settings.backup.json .claude/settings.local.json
   rm settings.backup.json
   
   # Commit
   git add .gitmodules .claude
   git commit -m "Convert .claude to submodule"
   ```

## Troubleshooting

### Working in Subdirectories

If notification scripts don't work when you're in subdirectories (e.g., `frontend/`, `backend/`), use the `--add-dir` flag:

```bash
# From project root
claude code --add-dir .

# From a subdirectory
cd frontend
claude code --add-dir ..
```

This ensures all `.claude` scripts and commands work properly regardless of your current directory.

### Submodule Issues

**"fatal: No url found for submodule path '.claude'"**
```bash
git submodule init
git submodule update
```

**Submodule is in detached HEAD state**
```bash
cd .claude
git checkout main
git pull
```

**Want to make local changes without affecting the submodule**
```bash
# Create a local branch
cd .claude
git checkout -b local-customizations
# Make your changes
# These won't be pushed to the main repository
```

## Best Practices

1. **Keep commands generic** - They should work across different project types
2. **Document changes** - Update DEV_EXPERIENCE_CHANGELOG.md
3. **Test before pushing** - Ensure commands work in a fresh project
4. **Share improvements** - If it helps you, it might help others
5. **Use semantic versioning** - Tag releases for easy version management

## Version Management

We use semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes to command structure
- **MINOR**: New commands or features
- **PATCH**: Bug fixes and minor improvements

Check releases at: https://github.com/yourusername/dot-claude/releases

## License

[Add your license here]