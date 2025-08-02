# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a template .claude directory that gets included in projects as a git submodule. It provides a structured workflow for software development with Claude Code, including generic custom commands, notification scripts, and settings for managing development tasks.

## Integration Method

This .claude directory is typically included as a git submodule, allowing projects to:
- Receive updates from the main dot-claude repository
- Maintain project-specific customizations
- Share improvements back to the community

### Checking Submodule Status
```bash
# Check if .claude is a submodule
git submodule status

# Update to latest version
/cmd-claude-update
```

## Project Structure

Every project using this template has:
- `docs/` - Local documentation and architecture notes
- `specs/` - Saved prompts and feature specifications  
- `FEATURES_CHANGELOG.md` - User-facing features and changes
- `DEV_EXPERIENCE_CHANGELOG.md` - Developer experience improvements
- `.claude/` - This directory (as a submodule)
  - `commands/` - Reusable command templates
  - `prompts/` - Generic AI assistance prompts
  - `scripts/` - Utility scripts
  - `settings.local.json` - Project-specific settings (not tracked in submodule)

[Update this section with project-specific information when using the template]

## Ticket Management System

**CONFIGURE THIS SECTION DURING PROJECT SETUP**

This project uses: [SELECT ONE AND REMOVE OTHERS]

### GitHub Issues
- **CLI Tool**: `gh` (GitHub CLI)
- **Installation**: `brew install gh` or visit https://cli.github.com/
- **Authentication**: `gh auth login`
- **Create Ticket**: `gh issue create --title "Title" --body "Description" --label enhancement`
- **Link Branch**: Use `Closes #123` in PR descriptions
- **Ticket URL Format**: `https://github.com/owner/repo/issues/123`

### Linear
- **CLI Tool**: `linear-cli` 
- **Installation**: `npm install -g @linear/cli`
- **Authentication**: `linear auth`
- **Create Ticket**: `linear issue create --title "Title" --description "Description"`
- **Link Branch**: Use `LIN-123` in branch names and commit messages
- **Ticket URL Format**: `https://linear.app/team/issue/LIN-123`

### Jira
- **CLI Tool**: `jira` (go-jira)
- **Installation**: `go install github.com/go-jira/jira/cmd/jira@latest`
- **Authentication**: Configure with `jira login`
- **Create Ticket**: `jira create --project PROJECT --type Story --summary "Title"`
- **Link Branch**: Use `PROJECT-123` in branch names
- **Ticket URL Format**: `https://company.atlassian.net/browse/PROJECT-123`

### GitLab Issues
- **CLI Tool**: `glab` (GitLab CLI)
- **Installation**: `brew install glab` or visit https://gitlab.com/gitlab-org/cli
- **Authentication**: `glab auth login`
- **Create Ticket**: `glab issue create --title "Title" --description "Description"`
- **Link Branch**: Use `Closes #123` in MR descriptions
- **Ticket URL Format**: `https://gitlab.com/owner/repo/-/issues/123`

## Essential Commands

### Common Development Commands
```bash
# Run tests (adapt to your project)
python -m pytest tests/ -v              # Python
npm test                                # Node.js
go test ./...                           # Go
cargo test                              # Rust

# Linting and formatting
black . && isort . && flake8 .          # Python
npm run lint && npm run format          # Node.js
gofmt -w . && golint ./...              # Go
cargo fmt && cargo clippy               # Rust

# Type checking
mypy . --ignore-missing-imports         # Python
tsc --noEmit                            # TypeScript

# Build/Run
python app.py                           # Python
npm start                               # Node.js
go run .                                # Go
cargo run                               # Rust
```

### Git Workflow Commands
```bash
# Start work on an issue
/cmd-issue-start

# Create feature documentation before PR
/cmd-feature-document

# Create pull request
/cmd-pr-create

# Complete issue after merge
/cmd-issue-complete

# Clean up git worktrees
/cmd-git-cleanup
```

## Architecture

### Custom Commands Structure
The `.claude/commands/` directory contains markdown-based command templates that guide development workflows:

- **Issue Management**: `cmd-issue-start.md`, `cmd-issue-create.md`, `cmd-issue-complete.md`
- **PR Workflow**: `cmd-pr-create.md`, `cmd-pr-review.md`, `cmd-pr-finalize.md`, `cmd-pr-implement-feedback.md`
- **Development**: `cmd-feature-document.md`, `cmd-worktree-create.md`, `cmd-git-cleanup.md`
- **Tools**: `cmd-mcp-install.md`

### Notification System
The repository includes a notification script (`scripts/notify-agent-complete.sh`) that sends desktop notifications for:
- Main agent completion
- Task completion
- When Claude needs user input
- When a tab needs attention

### Settings Configuration
The `settings.local.json.example` provides:
- Bash command permissions whitelist
- Hook configurations for notifications
- Integration with MCP (Model Context Protocol) servers

## Development Workflow

1. **Starting Work**: Use `/cmd-issue-start` to begin work on an issue. This follows TDD principles and creates a git worktree for the feature (if worktrees are used).

2. **During Development**: 
   - Write tests first (TDD approach)
   - Commit regularly with descriptive messages
   - Run tests frequently

3. **Before Creating PR**: Run `/cmd-feature-document` to:
   - Create a specification in `specs/` directory
   - Update FEATURES.md, CHANGELOG.md, or DEVELOPER_EXPERIENCE.md
   - Update README.md and CLAUDE.md if needed

4. **Creating PR**: Use `/cmd-pr-create` which ensures documentation is complete before creating the pull request.

5. **After Merge**: Run `/cmd-issue-complete` to clean up worktree and update all documentation.

## Key Patterns

### Test-Driven Development
- Always write tests before implementation
- Add security tests for any new endpoints or sensitive functionality
- Maintain high test coverage

### Documentation-First Approach
- Feature specifications are created before PRs
- Changes are categorized as either user-facing (FEATURES.md/CHANGELOG.md) or developer-focused (DEVELOPER_EXPERIENCE.md)
- Documentation is part of the development process, not an afterthought

### Git Worktree Usage
- Each feature is developed in its own worktree
- Worktrees are automatically cleaned up after merge
- Prevents conflicts between concurrent development tasks
- **Important**: When working in a worktree, all commands operate within that worktree's directory structure, not the parent repository

## Common Tasks

### Running Tests
```bash
# Python
python -m pytest tests/ -v --cov=.
python -m pytest tests/test_file.py -v
python -m pytest tests/test_file.py::test_function -v

# JavaScript/TypeScript
npm test
npm test -- --watch
npm test -- path/to/test.spec.js

# Go
go test ./...
go test -v ./pkg/...
go test -run TestSpecificFunction ./...

# Rust
cargo test
cargo test test_name
cargo test --lib
```

### Common Project Operations
```bash
# Package management
pip install -r requirements.txt         # Python
npm install                             # Node.js
go mod download                         # Go
cargo build                             # Rust

# Database migrations (if applicable)
alembic upgrade head                    # Python/Alembic
npm run migrate                         # Node.js
migrate -path ./migrations up          # Go

# Docker operations (if applicable)
docker-compose up -d
docker-compose logs -f
docker-compose down
```

## Important Notes

- Never commit sensitive information (API keys, tokens)
- Always check existing libraries before adding new dependencies
- Follow existing code conventions and patterns
- Use the notification system to alert when long-running tasks complete
- Feature branches should be linked to issues (GitHub, GitLab, Jira, etc.)

### Working in Subdirectories

When working in subdirectories (like `frontend/` or `backend/`), the notification scripts may not work properly due to relative paths. To fix this, use the `--add-dir` flag when starting Claude Code:

```bash
# Start from project root to ensure scripts work
claude code --add-dir .

# Or if you need to work in a specific directory
cd frontend
claude code --add-dir ..
```

This ensures that:
- Notification scripts can be found at `.claude/scripts/`
- All custom commands work properly
- Settings paths resolve correctly

## Working with the .claude Submodule

### Understanding the Setup
- The .claude directory is a git submodule pointing to the dot-claude repository
- Your `settings.local.json` is gitignored and remains project-specific
- Updates to commands/prompts can be pulled from the main repository

### Updating .claude
```bash
# Use the command
/cmd-claude-update

# Or manually
cd .claude
git pull origin main
cd ..
git add .claude
git commit -m "Update .claude to latest version"
```

### Making Local Customizations
If you need project-specific commands that shouldn't be shared:
1. Create them in your main project (outside .claude)
2. Or create a local branch in the submodule
3. Document them in your project's main CLAUDE.md

### Contributing Back
When you create useful improvements:
```bash
cd .claude
git checkout -b feature/your-improvement
# Make changes
git commit -m "Add: your improvement"
git push origin feature/your-improvement
# Create PR on GitHub
```