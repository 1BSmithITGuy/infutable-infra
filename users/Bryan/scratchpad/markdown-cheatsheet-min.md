# Markdown Cheat Sheet — Code + Result

Use VS Code preview (**Ctrl+K, V**) to see the result beside the source. Each item shows **the Markdown** and then **the rendered result**.

---

---
# Lists

**Code**
```md
- bullet
  - nested
1. ordered
2. ordered
```
---
## Code Blocks (with syntax)

**Code**
````md
```bash
kubectl get pods -A
```

```yaml
apiVersion: v1
kind: Pod
```
````

**Result**

```bash
kubectl get pods -A
```

```yaml
apiVersion: v1
kind: Pod
```

---
---
## Emphasis

**Code**
```md
*italics*  _also italics_
**bold**
~~strikethrough~~
`inline code`
```

**Result**

*italics*  _also italics_  
**bold**  
~~strikethrough~~  
`inline code`

---

## Tables

**Code**
```md
| Env | URL            | Notes     |
|-----|----------------|-----------|
| dev | dev.example.io | behind LB |
```

**Result**

| Env | URL            | Notes     |
|-----|----------------|-----------|
| dev | dev.example.io | behind LB |

---

# Headings

**Code**
```md
# H1
## H2
### H3
```

**Result**

# H1
## H2
### H3
---


## Links & Images

**Code**
```md
[text](https://example.com)
![alt text](data:image/png;base64, ...)
```

**Result**

[text](https://example.com)  
![alt text](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHgAAAAgCAIAAABW2ysfAAAA/klEQVR4nO2a2w3DIAxFnSoDMC4jZFxG6AcSsuxg2rTcKvSeL2QeSg7GKFK2nLOQ+ewiQtezOY7j8etn+BcoGgRFg6BoEBQNgqJBUDQIigaxx90ppdoopcx+lLUZZDT9fosoo1s6+0gpxfS2LYkPgZ9VI7qhR/r4TelmtH89HUkpmTevvWaMX7bNMuvohixnWS5chqeJvICI2QwuQw+dXqOb0eb466NdGc7S1bZX7nvbFhSfmxJltLdgIrpumOIbr2OCp3MXc/126fgQf0TiYbJKsUKLftHaGnI1/AQHQdEgKBoERYOgaBAUDYKiQVA0CIoGQdEgKBrExl9JMTwBt+uInW+3fkgAAAAASUVORK5CYII=)

---

## Blockquotes

**Code**
```md
> **Note:** important context.
> Second line continues with `>`.
```

**Result**

> **Note:** important context.  
> Second line continues with `>`.

---

## Horizontal Rule & Line Breaks

**Code**
```md
---
First line␠␠
Second line (forced break above with two spaces)
```

**Result**

---
First line  
Second line (forced break above with two spaces)

---

## Collapsible Details

**Code**
````md
<details>
  <summary>Kube commands</summary>

  ```bash
  kubectl config get-contexts
  ```
</details>
````

**Result**

<details>
  <summary>Kube commands</summary>

  ```bash
  kubectl config get-contexts
  ```
</details>

---

## Footnotes

**Code**
```md
A statement with a note.[^why]
[^why]: This is the footnote.
```

**Result**

A statement with a note.[^why]  
[^why]: This is the footnote.

---

## Minimal Daily Template

**Code**
````md
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
````

**Result**

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
