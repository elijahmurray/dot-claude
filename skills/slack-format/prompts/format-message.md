# Format Message for Slack

## Purpose
Convert content into Slack-ready mrkdwn format for easy copy-paste.

## Workflow

1. **Understand the Content**
   - What's being shared? (status update, announcement, summary, alert)
   - Who's the audience? (team, channel, individual)
   - What tone? (formal, casual, urgent)

2. **Read Formatting Reference**
   - Check `cookbook/slack-mrkdwn.md` for syntax
   - Remember: Slack mrkdwn ≠ standard Markdown!

3. **Apply Conversions**
   - `**bold**` → `*bold*`
   - `~~strike~~` → `~strike~`
   - `[text](url)` → `<url|text>`
   - `# Header` → `:emoji: *Header*`
   - `- item` → `• item`
   - `---` → `───────────────`

4. **Add Slack Elements**
   - Relevant emoji for visual scanning
   - Proper structure for readability
   - Quotes for context if needed
   - Links with display text

5. **Present as Copy-Paste Block**
   ```
   ────────── Copy below ──────────

   [formatted content here]

   ────────── End ──────────
   ```

## Message Types

### Status Update
```
:rocket: *[Title]*

*Status:* [In Progress/Complete/Blocked]
*[Key field]:* [Value]

_Summary:_
[Brief description]

• [Bullet point]
• [Bullet point]
```

### Announcement
```
:mega: *[Title]*

Hey team! :wave:

[Main message]

*Key points:*
• [Point 1]
• [Point 2]

[Call to action or next steps]
```

### Alert
```
:rotating_light: *[Alert Type]: [Title]*

*Status:* [Investigating/Resolved/Monitoring]
*Impact:* [Description]
*Started:* [Time]

[Details]

───────────────
:clock1: _Last updated: [Time]_
```

### Summary/Report
```
:memo: *[Report Title] - [Date]*

*Completed:*
:white_check_mark: [Item]
:white_check_mark: [Item]

*In Progress:*
:hourglass: [Item] ([percentage]%)

*Blocked:*
:x: [Item] ([reason])

───────────────
<[link]|[link text]>
```

### Quick Share (from conversation)
```
:speech_balloon: *Quick Update*

[Content from conversation, reformatted]

───────────────
_Shared from dev session_
```

## Tips

- Lead with emoji for visual scanning
- Use bold for key labels
- Keep lines short (mobile readability)
- Use quotes (`>`) for context or references
- End with action items or links when relevant
- Test in Slack's message composer if unsure

## Example Conversion

**Input (from conversation):**
```
We finished the auth rewrite. The main changes were:
- Switched to OAuth2
- Added refresh token rotation
- Fixed the session timeout bug

Still need to update the docs and run final testing.
```

**Output (Slack mrkdwn):**
```
────────── Copy below ──────────

:white_check_mark: *Auth Rewrite Complete*

We've finished the auth system rewrite! Main changes:

• Switched to OAuth2
• Added refresh token rotation
• Fixed session timeout bug

*Remaining:*
• Update documentation
• Final testing round

────────── End ──────────
```
