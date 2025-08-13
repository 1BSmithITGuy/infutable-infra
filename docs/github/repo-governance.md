# Repo Governance

## Branch model
- `main`: protected; demo-ready. Linear history, PRs only, no force-push, no deletions.
- `dev`: working branch; direct pushes allowed; deletions restricted.

## Protection rules
**main**
- Require pull request before merging (approvals: 0)
- Require conversation resolution
- Require linear history
- Restrict deletions
- Block force pushes
- Require status checks to pass (no required checks yet; will add CI later)
- Allowed merge methods: Squash (and optionally Rebase)

**dev**
- Restrict deletions (all else open for iteration)

## PR workflow
1. Work on `dev`; push freely.
2. Open PR `dev → main`.
3. CI runs (kustomize build + kubeconform) *(to be added)*.
4. Resolve comments, merge via **Squash**.

## Commit hygiene
- No secrets in Git. Use `.gitignore`, SOPS/age, or External Secrets.
- Prefer small, focused commits.

