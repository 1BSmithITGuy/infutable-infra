# Documentation Standards

Author: Bryan Smith  
Created: 2026-02-15  
Last Updated: 2026-02-17

## Revision History

| Date       | Author | Change Summary              |
|------------|--------|-----------------------------|
| 2026-02-15 | Bryan  | Initial document            |
| 2026-02-17 | Bryan  | added  logs, references     |

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
4. **Purpose** (one or two sentences)
5. **Prerequisites** (what must be in place before starting)
6. **Relevant logs**
7. **Steps** (numbered: `## Step 1: Description`, `## Step 2: Description`, etc.)
8. **Validation** (how to confirm it worked)
9. **References** (Don't go crazy here)

See `docs/templates/runbook-template.md` for a ready-to-copy starting point.

## Code Blocks

Always specify the language tag:

````markdown
```bash
sudo systemctl restart kubelet
```
````

Common tags: `bash`, `yaml`, `powershell`, `json`, `text`

## General Guidelines

- Write for someone who knows the technology but not your environment
- Include actual hostnames, IPs, and paths where relevant
- Keep it factual. If a step has a prerequisite, state it. If there is a known issue, note it.
- One README per directory. If a directory needs more than one doc, use separate `.md` files alongside the README.
