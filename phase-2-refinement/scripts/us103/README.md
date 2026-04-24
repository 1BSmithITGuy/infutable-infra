# Scripts

Orchestration wrappers that tie Terraform and Ansible together into a single command per deployment.

## Directory Structure

```
scripts/
    us103/
        deploy-dc.sh        Deploy a domain controller (Terraform + Ansible)
```

## Scripts

| Script | Description | Comments |
|--------|-------------|---------|
| `us103/deploy-dc.sh` | Pipeline - Deploy AD domain controllers | [DC Pipeline Documentation](../docs/pipelines/us103/domain-controller.md) |
