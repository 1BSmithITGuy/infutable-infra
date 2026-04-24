# Archive

Author: Bryan Smith  
Created: 2026-04-24  
Last Updated: 2026-04-24

## Revision History

| Date       | Author | Change Summary   |
|------------|--------|------------------|
| 2026-04-24 | Bryan  | Initial document |

## About

Earlier lab work from this repository, kept for reference. This content covers platform evaluation, Kubernetes experiments, and baseline site infrastructure. Documentation standards were still being developed, so conventions here differ from the current root-level work.

For current work and active standards, see [the repository root](../).

## Highlights

| Area | Description |
|------|-------------|
| [Site infrastructure](./docs/infra/sites/us103/) | Hardware, network, rack layout |
| [Jump station](./docs/runbooks/us103/jump-station/) | Server and workstation setup |
| [k3s cluster](./docs/runbooks/us103/k8s-infra/us103-k3s01/) | Lightweight k3s deployment |
| [kubeadm cluster](./docs/runbooks/us103/k8s-infra/us103-kubeadm01/) | Full kubeadm with Cilium BGP |
| [Cilium on Talos](./k8s/platform/clusters/us103-talos01/docs/) | CNI installation for Talos Linux |
| [Monitoring](./k8s/platform/monitoring/) | Prometheus + Grafana setup |
| [Orchestration](./orchestration/us103/) | Environment startup/shutdown automation |

## Note on patterns

Patterns, layouts, and tooling choices in this tree should not be referenced from current work. Site-level conventions (VLANs, subnets, hostname patterns) do carry forward and are documented at the repository root.
