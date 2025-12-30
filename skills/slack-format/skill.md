# Slack Format Skill

## Purpose
Format messages for Slack using Slack's mrkdwn syntax (not standard Markdown). Helps share status updates, summaries, and information from conversations in a copy-paste ready format.

## When to Activate
Activate this skill when the user:
- Asks to format something for Slack
- Wants to share a status update in Slack
- Says "format this for Slack" or "make this Slack-friendly"
- Wants to copy-paste something into Slack
- Asks for a Slack message or announcement

## Key Difference
Slack uses **mrkdwn**, NOT standard Markdown. The syntax is different!

## Quick Reference

| Element | Slack mrkdwn | Standard Markdown |
|---------|--------------|-------------------|
| Bold | `*text*` | `**text**` |
| Italic | `_text_` | `_text_` or `*text*` |
| Strike | `~text~` | `~~text~~` |
| Code | `` `text` `` | `` `text` `` |
| Code block | ` ```text``` ` | ` ```text``` ` |
| Link | `<url\|text>` | `[text](url)` |
| Quote | `>text` | `>text` |
| List | `• item` or `1. item` | `- item` or `1. item` |
| Header | ❌ Not supported | `# Header` |

## Workflow

1. Read `cookbook/slack-mrkdwn.md` for full syntax reference
2. Convert content to Slack format
3. Present as copy-paste ready block
4. Offer variations (brief/detailed, with/without emoji)

## Cookbook
- `cookbook/slack-mrkdwn.md` - Full Slack formatting reference

## Examples
- "format this update for Slack" → converts to mrkdwn
- "write a Slack message about the deploy" → creates formatted message
- "make this Slack-friendly" → converts markdown to mrkdwn
