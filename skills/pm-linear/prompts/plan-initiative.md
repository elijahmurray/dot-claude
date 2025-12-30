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
   - Rough size (small/medium/large)
   - Dependencies on other tickets
   - Milestone assignment

5. **Review Plan**

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
   - [ ] [Ticket title] (feature, medium)
   - [ ] [Ticket title] (chore, small)

   **Milestone 2: [Name]**
   - [ ] [Ticket title] (feature, large)
   ...

   ### Dependencies
   - Ticket X blocks Ticket Y
   - External: [Any external dependencies]

   ### Risks
   - [Potential risk and mitigation]

   ---
   Create this plan in Linear? (yes/no/edit)
   ```

6. **Create in Linear**

   If approved:
   - Create project first
   - Create tickets with project link
   - Set up dependencies
   - Add milestone labels or sub-projects

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
