# Roadmap Patterns

Best practices for managing roadmaps and projects in Linear.

## Project Lifecycle

```
Planned → Started → [Paused] → Completed
                 ↘ Canceled
```

### Status Definitions

| Status | Meaning | Actions |
|--------|---------|---------|
| **Planned** | Scoped, not started | Finalize scope, assign owner |
| **Started** | Active work underway | Track progress, remove blockers |
| **Paused** | Temporarily on hold | Document why, set resume date |
| **Completed** | Goals achieved | Retrospective, archive |
| **Canceled** | Won't be done | Document learnings |

## Project Naming

**Good:**
- "Migrate Authentication to OAuth2"
- "Q1 Mobile App Launch"
- "Reduce API Latency by 50%"

**Avoid:**
- "Auth stuff" (vague)
- "Project Alpha" (meaningless)
- "Misc improvements" (no clear goal)

**Pattern:** `[Action] [Target] [Outcome/Timeframe]`

## Milestone Strategy

### For Short Projects (2-4 weeks)
Skip formal milestones. Use issue priorities instead.

### For Medium Projects (1-3 months)
2-3 milestones:
1. **Foundation** - Setup, infrastructure
2. **Core** - Main features
3. **Launch** - Polish, release

### For Long Projects (3+ months)
Monthly milestones with clear deliverables. Consider breaking into multiple projects.

## Linking Issues to Projects

### When Creating Issues
Always ask: "Which project does this belong to?"

### Orphan Issues
Issues not linked to any project should be:
- Linked to an existing project, or
- Used to justify a new project, or
- Marked as standalone maintenance

### Issue-to-Project Ratio
- **Too few issues** (<5): Project may be too small or under-scoped
- **Too many issues** (>50): Consider splitting into sub-projects
- **Sweet spot**: 10-30 issues per project

## Target Dates

### Setting Dates
- Include buffer (20-30% extra time)
- Align with business milestones when possible
- Update promptly when reality changes

### Date Hygiene
- Past due + no activity = needs attention
- Frequently moved dates = scope problem
- No date = no accountability

## Progress Tracking

### What to Track
- Issues completed vs total
- Issues in progress
- Blocked issues (red flag)
- Scope changes (additions/removals)

### Review Cadence
- **Weekly**: Quick status check
- **Bi-weekly**: Detailed review, adjust priorities
- **Monthly**: Roadmap health, re-prioritization

## Project Health Signals

### 🟢 Healthy
- Issues moving through workflow
- On track for target date
- Clear owner engaged
- Recent activity (within 7 days)

### 🟡 At Risk
- Progress slower than expected
- Target date approaching with work remaining
- Owner unclear or unavailable
- No activity in 14+ days

### 🔴 Critical
- Past target date
- Blocked issues not being addressed
- No owner
- No activity in 30+ days

## Roadmap Meetings

### Agenda Template
1. **Review completed** (5 min)
   - What shipped since last meeting?

2. **At-risk projects** (15 min)
   - What's behind? Why? What do we do?

3. **New initiatives** (10 min)
   - What's coming? Capacity check.

4. **Priorities** (10 min)
   - Are we working on the right things?

### Outputs
- Updated project statuses
- Decisions on at-risk items
- New projects created
- Priorities clarified

## Quarterly Planning

### Before the Quarter
1. Review previous quarter outcomes
2. Gather new initiatives from stakeholders
3. Estimate capacity realistically
4. Create projects for approved initiatives
5. Set target dates

### During the Quarter
1. Weekly: Track progress
2. Bi-weekly: Adjust priorities
3. Monthly: Roadmap health check

### End of Quarter
1. Mark completed projects done
2. Carry over or cancel incomplete
3. Document learnings
4. Prepare next quarter plan

## Common Anti-Patterns

### The Zombie Project
**Symptom:** Project started months ago, no recent activity, not completed
**Fix:** Pause or cancel. Be honest about priority.

### The Scope Creeper
**Symptom:** Project keeps growing, target dates keep moving
**Fix:** Lock scope. New ideas go to separate projects.

### The Orphan Farm
**Symptom:** Many issues not linked to any project
**Fix:** Regular triage. Link or create projects.

### The Over-Planner
**Symptom:** Detailed projects planned far in advance
**Fix:** Only detail next 1-2 quarters. Keep backlog loose.

### The Status Ignorer
**Symptom:** Projects not updated, statuses stale
**Fix:** Weekly status ritual. Make it easy.
