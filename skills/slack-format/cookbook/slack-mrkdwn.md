# Slack mrkdwn Reference

Slack uses "mrkdwn" which is similar to Markdown but with key differences.

## Text Formatting

### Bold
```
*bold text*
```
⚠️ Single asterisks, NOT double!

### Italic
```
_italic text_
```

### Strikethrough
```
~strikethrough~
```
⚠️ Single tildes, NOT double!

### Inline Code
```
`inline code`
```

### Code Block
```
```code block
multiple lines
```
```

Or with language (though Slack highlighting is limited):
```
```python
def hello():
    print("hi")
```
```

## Links

### URL with Display Text
```
<https://example.com|Click here>
```
⚠️ Pipe character `|` separates URL and text, NOT `[text](url)`!

### Plain URL (auto-links)
```
https://example.com
```

### Email
```
<mailto:user@example.com|Email me>
```

### Mention User
```
<@U1234567890>
```

### Mention Channel
```
<#C1234567890>
```

### Special Mentions
```
<!here>     - notify active members
<!channel>  - notify all members
<!everyone> - notify everyone (workspace-wide)
```

## Lists

### Bullet List
```
• Item one
• Item two
• Item three
```
Use actual bullet character (•) or emoji. Dashes (-) don't render as bullets.

### Numbered List
```
1. First item
2. Second item
3. Third item
```

### Nested (limited support)
```
• Main item
   ◦ Sub item (use spaces + different bullet)
```

## Quotes

### Block Quote
```
> This is a quoted message
> Can span multiple lines
```

## Line Breaks

Single newline = same paragraph
Double newline = new paragraph

For visual separation:
```
───────────────
```
Or use blank line.

## Emoji

```
:thumbsup:
:white_check_mark:
:rotating_light:
:rocket:
:warning:
:x:
:heavy_check_mark:
:arrow_right:
:point_right:
:bulb:
:memo:
:calendar:
:clock1:
```

## What Slack Does NOT Support

❌ Headers (`#`, `##`, etc.) - Use bold + emoji instead
❌ Tables - Use code blocks or format manually
❌ Images in mrkdwn - Must use attachments/blocks
❌ Horizontal rules (`---`) - Use `───────` or emoji line
❌ Nested formatting (bold italic) - Limited support

## Common Patterns

### Status Update
```
:rocket: *Deploy Complete*

*Environment:* Production
*Version:* v2.3.1
*Time:* 3:45 PM EST

_Changes:_
• Fixed login timeout bug
• Added dark mode toggle
• Updated dependencies
```

### Announcement
```
:mega: *Announcement*

Hey team! :wave:

Quick update on the auth project:
> We've completed the OAuth integration and it's ready for testing.

*Next steps:*
1. QA review (Monday)
2. Staging deploy (Tuesday)
3. Production (Wednesday)

Questions? Drop them in thread :point_down:
```

### Alert/Warning
```
:rotating_light: *Alert: API Latency Spike*

*Status:* Investigating
*Impact:* ~5% of requests affected
*Started:* 2:30 PM EST

We're looking into elevated latency on the payments endpoint. Updates to follow.

───────────────
:clock1: _Last updated: 2:45 PM EST_
```

### Summary/Report
```
:memo: *Weekly Summary - Dec 30*

*Completed:*
:white_check_mark: Auth system rewrite
:white_check_mark: Mobile app v2.0 release
:white_check_mark: Database migration

*In Progress:*
:hourglass: API performance optimization (75%)
:hourglass: Dashboard redesign (40%)

*Blocked:*
:x: Payment gateway update (waiting on vendor)

───────────────
<https://linear.app/team/project/123|View in Linear>
```

## Converting from Markdown

| From (Markdown) | To (Slack mrkdwn) |
|-----------------|-------------------|
| `**bold**` | `*bold*` |
| `~~strike~~` | `~strike~` |
| `[text](url)` | `<url\|text>` |
| `# Header` | `:emoji: *Header*` |
| `- item` | `• item` |
| `---` | `───────────────` |
