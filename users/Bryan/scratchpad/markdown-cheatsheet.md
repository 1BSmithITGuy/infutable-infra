# Markdown Notes Cheat Sheet

A compact, practical guide tuned for fast note‑taking. Everything here renders in VS Code and on GitHub.

---

## Core moves
Headings you know: `#`, `##`, `###`

**Emphasis**
```md
*italics*  _also italics_
**bold**
~~strikethrough~~
`inline code`
```

**Lists & tasks**
```md
- bullets
  - nested bullet
1. ordered
2. ordered again

- [ ] todo
- [x] done
```

**Links & images**
```md
[text](https://example.com)
![alt text](_img/screenshot.png)   <!-- relative path = portable -->
<https://example.com>              <!-- autolink -->
```

**Code blocks (with syntax highlighting)**
```md
```bash
kubectl get pods -A
```

```yaml
apiVersion: v1
kind: Pod
```

```diff
+ added line
- removed line
```
```

**Blockquotes & callouts**
```md
> **Note:** this is important context.
> Multiline? Just keep using `>`.
```

**Horizontal rule & line breaks**
```md
---   <!-- or *** -->
Line 1  
Line 2  <!-- two spaces at end = hard line break -->
```

**Tables (GitHub‑flavored Markdown)**
```md
| Env | URL            | Notes     |
|-----|----------------|-----------|
| dev | dev.example.io | behind LB |
```

**Footnotes (GitHub‑flavored)**
```md
Statement that needs a cite.[^why]
[^why]: Your footnote lives here.
```

**Collapsible details (HTML works in Markdown)**
```md
<details>
  <summary>Kube commands I keep forgetting</summary>

  ```bash
  kubectl config get-contexts
  ```
</details>
```

---

## Workflow tips that actually help
- Keep images **next to the note**: use a path like `${currentFileDir}/_img` so links stay relative and portable.
- Use **Markdown All in One** (VS Code extension):
  - `Create Table of Contents` command to auto-generate a ToC.
  - List continuation and handy shortcuts for headings/formatting.
- Use **anchors** to jump around a long note (IDs are auto‑generated from headings):
  ```md
  [Inbox](#inbox) • [Notes](#notes) • [Commands](#commands)
  ```
- Prefer fenced code blocks for commands; they copy cleanly.
- For quick design diffs, use the `diff` fence to show adds/removes.

---

## Minimal daily template
```md
# 2025-08-18

[Inbox](#inbox) • [Notes](#notes) • [Commands](#commands)

## Inbox
- [ ] …

## Notes
> **Decision:** …

## Commands
```bash
# what I actually ran
```

## Links
- [Runbook](../somewhere/README.md)
```
