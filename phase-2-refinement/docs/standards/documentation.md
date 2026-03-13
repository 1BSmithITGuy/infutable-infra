# Documentation Standards

Author: Bryan Smith  
Created: 2026-02-15  
Last Updated: 2026-02-17

## Revision History

| Date       | Author | Change Summary              |
|------------|--------|-----------------------------|
| 2026-02-15 | Bryan  | Initial document            |
| 2026-02-17 | Bryan  | added  logs, references     |
| 2026-03-09 | Bryan  | added  notes regarding tooling logs     |

---

## Dates

All dates use ISO 8601 format: `YYYY-MM-DD`

## File Naming

- Directories: `kebab-case` (lowercase, hyphens)
- Use `README.md` for directory index files
- Supporting files use `kebab-case` with appropriate extensions

## Document Headers

Every document starts with plain metadata lines, then a revision history table:

```markdown
# Document Title

Author: Bryan Smith  (2 spaces)
Created: YYYY-MM-DD  (2 spaces)
Last Updated: YYYY-MM-DD 

## Revision History

| Date       | Author | Change Summary        |
|------------|--------|-----------------------|
| YYYY-MM-DD | Bryan  | Initial document      |
```

## Runbook Structure

Runbooks follow this section order:

1. **Title** (`# Title`)
2. **Metadata lines**
3. **Revision history**
4. **Purpose** 
5. **Prerequisites** 
6. **Relevant logs**
7. **Steps** (numbered: `## Step 1: Description`, `## Step 2: Description`, etc.)
8. **Validation** 
9. **References** 

See `docs/templates/runbook-template.md` for a ready-to-copy starting point.

## Logging
* All tooling logs follow the standard defined in `docs/standards/logging.md`. 
* Runbooks should reference relevant log paths in their **Relevant logs** section.
