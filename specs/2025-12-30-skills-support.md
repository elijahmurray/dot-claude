# Skills Support Feature Specification

**Date**: 2025-12-30
**Feature**: skills-support
**Status**: Complete

## Overview

Added Skills support to the dot-claude template. Skills are agent-invoked behaviors that activate automatically based on context, complementing the existing manual slash commands. The first skill implemented is `pm-linear` for product management and ticket writing workflows with Linear integration.

## User Requirements

- Add Skills pattern to support agent-invoked (automatic) behaviors
- Create a PM/Linear skill for ticket writing, bug triage, and backlog management
- Skills should use progressive disclosure (cookbook files only loaded when relevant)
- Preserve all existing commands/prompts/scripts functionality

## Technical Specifications

### Implementation Details

Skills follow a structured pattern:
- `skill.md` - Main file defining activation triggers, variables, and workflow
- `prompts/` - Individual prompt templates for specific tasks
- `cookbook/` - Reference docs loaded conditionally (progressive disclosure)

The pm-linear skill activates when users:
- Ask to write, create, or draft tickets/issues/stories
- Want to triage or categorize bugs
- Discuss prioritization or backlog management
- Reference Linear or ticket management

### Files Created

```
skills/
├── README.md                              # Skills vs commands explanation
└── pm-linear/
    ├── skill.md                           # PM workflow definition
    ├── prompts/
    │   ├── write-ticket.md                # Draft new tickets
    │   ├── triage-bug.md                  # Categorize bugs
    │   ├── update-ticket.md               # Modify tickets
    │   └── batch-review.md                # Review multiple tickets
    └── cookbook/
        ├── ticket-templates.md            # Bug/feature/chore templates
        ├── pm-style-guide.md              # Writing conventions
        └── linear-patterns.md             # Linear workflows
```

### Files Modified

- `CLAUDE.md` - Added Skills section under Architecture, updated Project Structure
- `settings.local.json.example` - Added protection rules and Linear MCP config

### Key Decisions Made

1. **Skills complement commands, don't replace them** - Commands for explicit one-off workflows, skills for repeat patterns
2. **Progressive disclosure** - Cookbook files only read when relevant to reduce context usage
3. **Linear MCP integration** - Skills designed to work with Linear MCP server for actual ticket creation
4. **Protection rules** - Skills files protected from modification like other .claude files, but readable

## Testing Requirements

- Test skill activation with prompts like "write a ticket for the auth bug"
- Verify Linear MCP server configuration works when enabled
- Ensure existing commands/scripts continue to function

## Dependencies

- Linear MCP server (optional, for actual ticket creation): `npx -y @linear/mcp-server`

## Future Considerations

- Additional skills could be added (e.g., code-review, deployment, testing)
- Skills could be enabled/disabled per project via configuration
- Cross-skill composition for complex workflows

## Workspace Config Enhancement (added)

The pm-linear skill now includes workspace config sync:
- Auto-fetches labels, teams, projects, states from Linear
- Caches to `.claude/linear-workspace.json`
- Auto-refreshes weekly or on-demand
- Uses actual workspace labels instead of generic suggestions

## Roadmap Management Enhancement (added)

Full project lifecycle and roadmap management:
- `prompts/manage-project.md` - Create, update, change project status
- `prompts/roadmap-review.md` - Review roadmap health, identify at-risk projects
- `prompts/plan-initiative.md` - Break initiatives into projects + milestones + tickets
- `cookbook/roadmap-patterns.md` - Best practices for roadmap management

## Implementation Notes

Skills differ from commands in invocation:
- Commands: User types `/cmd-*` to explicitly trigger
- Skills: Agent recognizes context and applies automatically

The pm-linear skill includes comprehensive templates for bugs, features, chores, and improvements, plus style guides for consistent ticket writing.
