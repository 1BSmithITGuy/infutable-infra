  # Phase 1: Exploration

  Initial lab buildout covering platform evaluation, tooling experiments,
  and baseline infrastructure. Documentation standards were developed
  iteratively during this phase.

  For current platform work with established standards, see
  [Phase 2](../phase-2-refinement/).

  ## Highlights

  | Area | Description |
  |------|-------------|
  | [Site Infrastructure](./docs/infra/sites/us103/) | Hardware, network, rack layout |
  | [Jump Station](./docs/runbooks/us103/jump-station/) | Server and workstation setup |
  | [k3s Cluster](./docs/runbooks/us103/k8s-infra/us103-k3s01/) | Lightweight k3s deployment |
  | [kubeadm Cluster](./docs/runbooks/us103/k8s-infra/us103-kubeadm01/) | Full kubeadm with Cilium BGP |
  | [Cilium on Talos](./k8s/platform/clusters/us103-talos01/docs/) | CNI installation for Talos Linux |
  | [Monitoring](./k8s/platform/monitoring/) | Prometheus + Grafana setup |
  | [Orchestration](./orchestration/us103/) | Environment startup/shutdown automation |
