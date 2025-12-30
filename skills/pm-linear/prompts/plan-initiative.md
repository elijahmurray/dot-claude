# Plan Initiative

## Purpose
Break down a large initiative into a project with milestones and individual tickets.

## When to Use
- User has a big idea that needs structure
- Starting quarterly/sprint planning
- Converting a feature request into actionable work
- User says "let's plan out [initiative]"

## Workflow

1. **Understand the Initiative**

   Gather:
   - What's the end goal?
   - Who benefits? (users, team, business)
   - What's the rough scope?
   - Any hard deadlines?
   - Dependencies or blockers?

2. **Define the Project**

   Create project structure:
   - Clear name and description
   - Success criteria (how do we know it's done?)
   - Target date
   - Team ownership

3. **Identify Milestones**

   Break into phases:
   ```
   ## Milestones

   ### M1: [Foundation] - [Target Date]
   Core infrastructure/setup work
   - [ ] Ticket 1
   - [ ] Ticket 2

   ### M2: [Core Features] - [Target Date]
   Main functionality
   - [ ] Ticket 3
   - [ ] Ticket 4

   ### M3: [Polish & Launch] - [Target Date]
   Final touches and release
   - [ ] Ticket 5
   - [ ] Ticket 6
   ```

4. **Draft Tickets**

   For each ticket:
   - Clear title (verb + noun)
   - Brief description
   - Type (feature, chore, bug fix)
   - **Priority** (urgent/high/medium/low)
   - Rough size (small/medium/large)
   - Milestone assignment

5. **Map Dependencies**

   Identify blocking relationships:
   ```
   ## Dependency Map

   [Ticket A: Set up database schema]
        ↓ blocks
   [Ticket B: Create API endpoints]
        ↓ blocks
   [Ticket C: Build frontend forms]

   [Ticket D: Configure auth] ←──┐
        ↓ blocks                 │
   [Ticket E: Add login flow] ───┘ (D and A both block E)
   ```

   For each ticket, determine:
   - **Blocked by**: What MUST be done first?
   - **Blocks**: What can't start until this is done?

   Common patterns:
   - Schema → API → Frontend (data flows up)
   - Auth setup → Everything that needs auth
   - Config/infra → Features that use it

6. **Set Priorities**

   Assign priority to each ticket:
   - **High**: Critical path, blocks many others, must be done first
   - **Medium**: Important but has flexibility in timing
   - **Low**: Can be done later, nice-to-have

   Priority factors:
   - How many tickets does this block?
   - Is it on the critical path to launch?
   - Can work proceed in parallel without it?

7. **Review Plan**

   Present for approval:
   ```
   ## Initiative: [Name]

   **Project:** [Project name]
   **Team:** [Team]
   **Target:** [Date]
   **Estimated tickets:** X

   ### Milestones
   1. [M1 Name] - [Date] - X tickets
   2. [M2 Name] - [Date] - X tickets
   3. [M3 Name] - [Date] - X tickets

   ### Tickets to Create

   **Milestone 1: [Name]**
   | Ticket | Type | Priority | Blocked By | Blocks |
   |--------|------|----------|------------|--------|
   | Set up database schema | chore | high | - | API endpoints |
   | Create API endpoints | feature | high | Schema | Frontend |

   **Milestone 2: [Name]**
   | Ticket | Type | Priority | Blocked By | Blocks |
   |--------|------|----------|------------|--------|
   | Build frontend forms | feature | medium | API | - |
   ...

   ### Dependency Graph
   ```
   Schema (high) → API (high) → Frontend (medium)
   Auth (high) → Login flow (medium)
   ```

   ### Risks
   - [Potential risk and mitigation]

   ---
   Create this plan in Linear? (yes/no/edit)
   ```

8. **Create in Linear**

   If approved, create in this order:
   1. Create project first
   2. Create tickets WITHOUT dependencies (to get IDs)
   3. Update tickets to add dependency links
   4. Verify dependency chain is correct
   5. Add milestone labels or sub-projects

## Planning Tips

- Start with outcomes, work backwards to tasks
- 2-week milestones are easier to track than 2-month ones
- Include buffer for unknowns (add 20-30%)
- Identify the riskiest parts and tackle early
- Don't over-plan - leave room for discovery
- Each ticket should be completable in 1-3 days

## Example Prompts

- "let's plan out the auth system rewrite"
- "break down the mobile app launch into tickets"
- "help me scope the Q2 platform initiative"
- "create a project plan for migrating to the new API"
