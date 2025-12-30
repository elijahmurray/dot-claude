# Manage Project

## Purpose
Create, update, or manage Linear projects (roadmap items) for organizing work around initiatives.

## When to Use
- User wants to create a new project/initiative
- User wants to update project status, dates, or description
- User asks about project health or progress
- User wants to archive or complete a project

## Variables
- `$PROJECT_NAME`: Name of the project
- `$TEAM`: Team that owns the project
- `$TARGET_DATE`: Target completion date (optional)
- `$STATUS`: Project status (planned, started, paused, completed, canceled)

## Workflow

### Creating a New Project

1. **Check Workspace Config**
   - Load teams from `.claude/linear-workspace.json`
   - Identify appropriate team for the project

2. **Gather Project Details**
   - Name: Clear, descriptive (e.g., "Q1 Auth Improvements")
   - Description: Goals, scope, success criteria
   - Target date: When should this be done?
   - Team: Which team owns this?
   - Lead: Who's responsible? (optional)

3. **Draft Project**
   ```
   ## Project: [Name]

   **Team:** [Team]
   **Target Date:** [Date]
   **Lead:** [Person] (optional)

   ### Description
   [What this project aims to achieve]

   ### Goals
   - [ ] Goal 1
   - [ ] Goal 2

   ### Success Criteria
   - [How we know it's done]

   ### Scope
   **In scope:**
   - [Included work]

   **Out of scope:**
   - [Explicitly excluded]

   ---
   Ready to create in Linear? (yes/no/edit)
   ```

4. **Create in Linear**
   - Use Linear MCP to create project
   - Assign to team
   - Set target date and status

### Updating a Project

1. **Identify Project**
   - Get project name or ID from user
   - Query Linear MCP for current state

2. **Determine Update Type**
   - Status change (planned → started → completed)
   - Target date adjustment
   - Description/scope update
   - Adding/removing milestones

3. **Make Update**
   - Use Linear MCP to update project
   - Add update comment if significant change

4. **Confirm**
   - Show updated project details
   - Note any linked issues affected

### Project Status Guide

| Status | When to Use |
|--------|-------------|
| **Planned** | Scoped but not started |
| **Started** | Actively being worked on |
| **Paused** | Temporarily on hold |
| **Completed** | All goals achieved |
| **Canceled** | Won't be done |

## Tips

- Keep project names action-oriented: "Migrate to new API" not "API Migration"
- Set realistic target dates - better to extend than miss
- Link related issues immediately after creating
- Update status promptly when things change
- Add milestones for long projects (>1 month)
