# Skills

Skills are agent-invoked behaviors that activate automatically based on context. Unlike slash commands (which you manually invoke with `/cmd-*`), skills are triggered when the agent recognizes a relevant situation.

## Skills vs Commands vs Prompts

| Type | Invoked By | Use Case |
|------|------------|----------|
| **Commands** (`/cmd-*`) | You (manual) | One-off tasks, explicit workflows |
| **Prompts** | You (manual) | Reusable prompt templates |
| **Skills** | Agent (automatic) | Repeat solutions for a problem domain |

## When to Use Skills

Use skills when:
- You have a **repeat workflow** that should activate based on context
- **One prompt isn't enough** - you need multiple related capabilities
- You want **progressive disclosure** - load context only when needed

## Skill Structure

Each skill has:
- `skill.md` - Main file defining when to use, variables, and workflow
- `prompts/` - Individual prompt templates for specific tasks
- `cookbook/` - Reference docs loaded conditionally (progressive disclosure)

## Available Skills

- **pm-linear** - Product management and ticket writing with Linear integration
- **slack-format** - Format messages for Slack using mrkdwn syntax (not standard Markdown)
