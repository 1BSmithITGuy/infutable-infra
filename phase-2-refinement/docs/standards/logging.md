# Logging Standards

Author: Bryan Smith  
Created: 2026-03-09  
Last Updated: 2026-03-09  

## Revision History

| Date       | Author | Change Summary              |
|------------|--------|-----------------------------|
| 2026-03-09 | Bryan  | Initial document            |

---

## Purpose

Defines logging standards for all infrastructure tooling.

## Log Directory Structure

```
/srv/logs/<appname>/<task>/
```

Mirror the repo directory structure where it makes sense. Examples:

| Tool      | Repo path                            | Log path                                       |
|-----------|--------------------------------------|-------------------------------------------------|
| Packer    | `packer/windows-server-2022-core/`   | `/srv/logs/packer/windows-server-2022-core/`    |
| Terraform | `terraform/us103/dc03/`              | `/srv/logs/terraform/us103/dc03/`               |
| Ansible   | `ansible/`                           | `/srv/logs/ansible/`                            |


## Log File Naming

```
YYYY-MM-DD_HHMMSS_<type>.log
```

- Timestamp at the start so logs sort chronologically
- `<type>` describes the log content: `build`, `debug`, `apply`, `plan`, `playbook`, etc.

Example:

```
2026-03-09_143022_build.log     # packer build console output
2026-03-09_150500_apply.log     # terraform apply output
```

## Retention

No automated retention policy yet. See the "To Do" section below for planned improvements.

## Tool-Specific Notes

### Packer

Use `build.sh` wrapper script (example in `packer/windows-server-2022-core/`). 

### Terraform

```bash
export TF_LOG=INFO
export TF_LOG_PATH=/srv/logs/terraform/us103/dc03/$(date +%F_%H%M%S)_debug.log
terraform apply 2>&1 | tee /srv/logs/terraform/us103/dc03/$(date +%F_%H%M%S)_apply.log
```

### Ansible

Ansible logging is configured in `ansible.cfg`:

```ini
[defaults]
log_path = /srv/logs/ansible/ansible.log
```

> **Note:** Ansible's built-in `log_path` writes a single rolling log. For per-run logs with timestamps, a wrapper script or callback plugin is better.

---

## To Do

- [ ] **Log retention policy** - Define how long logs are kept and automate cleanup (e.g., cron job to remove logs older than 90 days)
- [ ] **Centralized log management** - Consolidate logs from all hosts into a single platform. Evaluate options like Graylog, OpenSearch (ELK alternative), or Loki + Grafana. See `future-project-ideas.md` for scope.
- [ ] **Terraform wrapper script** - Similar to the Packer wrapper
- [ ] **Ansible per-run logging** - Wrapper script or callback plugin
