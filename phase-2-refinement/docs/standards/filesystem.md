# Filesystem Conventions

Author: Bryan Smith
Created: 2026-03-22
Last Updated: 2026-03-22

## Revision History

| Date       | Author | Change Summary              |
|------------|--------|-----------------------------|
| 2026-03-22 | Bryan  | Initial document            |

---

## Purpose

Defines where to place infrastructure files on local servers/clients. This applies to automation/provisioning, bootstrap scripts, logs, and any other org files/scripts written to systems.

> For log standards with automation/provisioning (on the jump host/server), see [logging.md](logging.md).

## Principles

- All infrastructure scripts that run on the local server/client live under a single root.
- Directories should be named after the tool and/or purpose (automation-logs, packer, etc)
- Follow OS conventions and not identical paths across platforms (see below).
- `Clean up` - files are removed by the tool that created them if they are no longer needed.

## Windows

Root: `C:\ProgramData\Infutable\`

### Examples:

Temporary files created during template builds by Packer and VM provisioning by Terraform are stored in the below directories (and removed once complete):

```
C:\ProgramData\Infutable\bootstrap\packer\         
C:\ProgramData\Infutable\bootstrap\terraform\     
```


## Linux



| Purpose | Path |
|---------|------|
| Tooling and scripts | `/opt/infutable/` |
| Configuration | `/etc/infutable/` |
| Logs | `/var/log/infutable/` |
| Persistent state/data | `/var/lib/infutable/` |
| Bootstrap artifacts | `/opt/infutable/bootstrap/` |

## Automation Controller/Server paths (jump host)

Also see [logging.md](logging.md) for details.

```
/srv/repos/infutable-infra/         Git repo
/srv/logs/                          Logs (see logging standard)
```

## Scheduled task naming

Windows scheduled tasks the convention: `Infutable-<Purpose>`, and must be removed once no longer needed.

## References

- [Automation logging standards](logging.md)
- [documentation standards](documentation.md)