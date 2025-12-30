# Roadmap Review

## Purpose
Review project/roadmap health, identify at-risk initiatives, and provide status updates.

## When to Use
- User asks "how's the roadmap looking?"
- User wants to review project status
- Preparing for planning meetings
- Checking for at-risk or stale projects

## Workflow

1. **Fetch Projects**
   - Use Linear MCP to query all active projects
   - Filter by team if specified
   - Include: name, status, target date, progress, issue counts

2. **Analyze Health**

   **At Risk Indicators:**
   - Target date in past or within 2 weeks with low progress
   - No activity in 14+ days
   - High ratio of blocked issues
   - No assigned lead

   **Healthy Indicators:**
   - On track for target date
   - Recent activity
   - Issues moving through workflow
   - Clear ownership

3. **Calculate Progress**
   - Count completed vs total issues
   - Note blocked issues separately
   - Consider issue points/estimates if available

4. **Present Summary**
   ```
   ## Roadmap Review - [Date]

   ### Overview
   **Total Active Projects:** X
   **On Track:** X | **At Risk:** X | **Blocked:** X

   ---

   ### 🟢 On Track

   **[Project Name]** - [Team]
   - Target: [Date]
   - Progress: X/Y issues (Z%)
   - Last activity: [Date]

   ---

   ### 🟡 At Risk

   **[Project Name]** - [Team]
   - Target: [Date] ⚠️ [X days away]
   - Progress: X/Y issues (Z%)
   - Risk: [Why it's at risk]
   - Recommendation: [What to do]

   ---

   ### 🔴 Blocked/Stale

   **[Project Name]** - [Team]
   - Target: [Date]
   - Issue: [What's blocking]
   - Last activity: [X days ago]
   - Action needed: [Suggested action]

   ---

   ### Recommendations
   1. [Priority action item]
   2. [Secondary action]
   3. [Consider for next planning]
   ```

5. **Offer Actions**
   - Update stale project statuses
   - Adjust target dates
   - Flag blockers for discussion
   - Archive completed projects

## Questions to Surface

- Any projects past their target date?
- Any projects with no recent activity?
- Any projects missing owners?
- Any projects that should be paused or canceled?
- Any completed projects not marked as done?

## Filters

Support filtering by:
- Team: "review engineering roadmap"
- Status: "show started projects"
- Timeframe: "projects due this quarter"
- Health: "show at-risk projects"
