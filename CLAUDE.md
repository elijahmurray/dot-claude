# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Claude boilerplate repository that provides a structured workflow for software development with Claude Code. It includes generic custom commands, notification scripts, and settings for managing development tasks using git worktrees, GitHub issues, and pull requests across any project.

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