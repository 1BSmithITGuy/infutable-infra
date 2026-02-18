# InfUtable Infrastructure

**InfUtable** (from **immUTABLE** + **INFRAstructure**) is a production-style enterprise environment designed to demonstrate infrastructure automation, platform engineering, and operational discipline.

This repository is a technical portfolio maintained by Bryan Smith.

---

## Repository Structure

```
infutable-infra/
├── VMware/                    # Enterprise PowerCLI inventory tooling (archived)
├── phase-1-exploration/       # Initial lab buildout and platform evaluation
├── phase-2-refinement/        # Current: production-style k3s platform on Rocky Linux
│   ├── docs/
│   │   ├── standards/
│   │   ├── templates/
│   │   └── runbooks/
│   │       └── us103/
│   ├── k8s/
│   ├── terraform/
│   └── orchestration/
└── README.md
```

### VMware

Production-style [PowerCLI inventory engine](./VMware) built for environment-wide vSphere reporting. Uses direct API access (`Get-View`) with external data correlation for warranty, site, and lifecycle tracking. This is an archive and not in production.

### Phase 1: Exploration

Initial lab infrastructure built to evaluate tooling and establish baseline patterns. Includes work across k3s, kubeadm, Talos, XCP-ng, Cilium, and ArgoCD. Documentation standards were developed iteratively during this phase.

See [phase-1-exploration/](./phase-1-exploration/) for details.

### Phase 2: Refinement (Current)

Platform rebuild with established standards and a focused toolset:

- **OS:** Rocky Linux (RHEL ecosystem)
- **Kubernetes:** k3s (3-node cluster)
- **GitOps:** ArgoCD
- **Identity:** Active Directory with LDAPS
- **Observability:** Prometheus + Grafana
- **Backup:** TrueNAS with offsite replication

See [phase-2-refinement/](./phase-2-refinement/) for details.

All phase 2 documentation follows the project [documentation standards](./phase-2-refinement/docs/standards/documentation.md).

---

## Tools

| Domain             | Tool                          |
|--------------------|-------------------------------|
| Hypervisor         | Proxmox                       |
| VM Provisioning    | Terraform                     |
| Kubernetes         | k3s on Rocky Linux            |
| GitOps             | ArgoCD                        |
| Ingress            | NGINX Ingress Controller      |
| TLS (Kubernetes)   | cert-manager                  |
| TLS (AD/LDAPS)     | AD CS (Enterprise Root CA)    |
| Monitoring         | Prometheus + Grafana           |
| Backup Storage     | TrueNAS                       |
| Identity           | Active Directory + LDAPS       |
