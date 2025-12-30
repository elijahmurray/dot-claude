# Batch Review Tickets

## Purpose
Review multiple tickets for prioritization, cleanup, or status updates.

## Workflow

1. **Query Tickets**
   - Use Linear MCP to fetch tickets by criteria
   - Filter: team, status, assignee, label, date range

2. **Analyze**
   - Group by theme or area
   - Identify duplicates or related tickets
   - Flag stale tickets (no updates in X days)
   - Spot priority mismatches

3. **Present Summary**
   ```
   ## Ticket Review Summary

   **Total:** X tickets
   **By Status:** X todo, X in progress, X blocked
   **By Priority:** X urgent, X high, X medium, X low

   ### Recommendations
   - [ticket] should be higher priority because...
   - [ticket] and [ticket] appear to be duplicates
   - [ticket] is stale - needs update or closure
   ```

4. **Take Action**
   - Offer to update priorities
   - Offer to close stale tickets
   - Offer to merge duplicates
