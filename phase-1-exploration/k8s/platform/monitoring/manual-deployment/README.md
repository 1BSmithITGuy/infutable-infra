# Monitoring Stack

Production-grade monitoring infrastructure for infUTable homelab using Prometheus and Grafana.

## Architecture

```
┌─────────────────────────────────────────────────┐
│           us103-kubeadm01 (Primary)             │
│                                                  │
│  ┌────────────┐        ┌────────────┐          │
│  │ Prometheus │───────▶│  Grafana   │          │
│  │            │        │            │          │
│  └─────┬──────┘        └────────────┘          │
│        │                                        │
│        ▼                                        │
│  ┌─────────────────────────────────┐           │
│  │ Service Discovery & Scraping:    │           │
│  │ - Kubernetes API                 │           │
│  │ - Nodes (kubelet, cAdvisor)     │           │
│  │ - Pods & Services               │           │
│  │ - NGINX Ingress                 │           │
│  └─────────────────────────────────┘           │
└─────────────────────────────────────────────────┘
         │
         │ Future: Federation/Remote Write
         ▼
┌─────────────────────────────────────────────────┐
│              us103-k3s01 (Secondary)            │
│         (Prometheus agent/exporter only)         │
└─────────────────────────────────────────────────┘
```

## Components

### Prometheus
- **Version**: v2.47.2
- **Purpose**: Metrics collection, storage, and querying
- **Features**:
  - Auto-discovery of Kubernetes resources
  - 15-day retention (configurable)
  - Service discovery for pods/services with annotations
  - Ready for federation with other clusters

### Grafana
- **Version**: 10.2.0
- **Purpose**: Visualization and dashboards
- **Access**: http://grafana.us103kubeadm01.infutable.com
- **Default Login**: admin / infutable-admin (change immediately!)

## Directory Structure

```
platform/monitoring/
├── base/                      # Base configurations
│   ├── namespace.yaml
│   ├── kustomization.yaml
│   ├── prometheus/           # Prometheus components
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── rbac.yaml
│   │   └── service.yaml
│   └── grafana/             # Grafana components
│       ├── configmap.yaml
│       ├── deployment.yaml
│       ├── ingress.yaml
│       └── service.yaml
└── overlays/                # Site-specific configurations
    └── us103-kubeadm01/
        ├── kustomization.yaml
        ├── prometheus-config.yaml
        ├── prometheus-pvc.yaml
        ├── grafana-pvc.yaml
        └── *-patch.yaml files
```

## Deployment

### Prerequisites
- Kubernetes cluster with NGINX ingress controller
- kubectl configured with cluster access
- DNS entries for grafana.us103kubeadm01.infutable.com

### Deploy to Primary Cluster (us103-kubeadm01)
```bash
cd platform/monitoring
./deploy.sh kubeadm
```

### Dry Run
```bash
./deploy.sh dry-run
```

## Monitoring Targets

### Currently Configured
- **Kubernetes Components**:
  - API Server metrics
  - Node/kubelet metrics
  - cAdvisor (container metrics)
  - Pod/Service discovery via annotations
  - NGINX Ingress controller

### To Enable Pod/Service Monitoring
Add these annotations to your pods/services:
```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"    # Your metrics port
  prometheus.io/path: "/metrics" # Optional, defaults to /metrics
```

## Adding Custom Dashboards

1. Import dashboards from [Grafana Labs](https://grafana.com/grafana/dashboards/):
   - Kubernetes Cluster Monitoring: 8588
   - NGINX Ingress Controller: 9614
   - Node Exporter Full: 1860

2. Access Grafana → Import → Enter dashboard ID

## Next Steps

### Phase 1 (Current)
- [x] Deploy Prometheus + Grafana
- [ ] Import essential dashboards
- [ ] Configure alerts (Discord/Email)
- [ ] Add persistent storage optimization

### Phase 2 (Upcoming - separate chat)
- [ ] Deploy Loki + Promtail for logs
- [ ] Deploy Uptime Kuma for uptime monitoring
- [ ] Add node-exporter on XCP-ng hosts

### Phase 3 (Future)
- [ ] Federation with K3s cluster
- [ ] Add Thanos for long-term storage
- [ ] Custom application metrics
- [ ] SLO/SLI tracking

## Troubleshooting

### Check Prometheus Targets
```bash
kubectl -n monitoring port-forward svc/prometheus 9090:9090
# Visit http://localhost:9090/targets
```

### View Prometheus Logs
```bash
kubectl -n monitoring logs deployment/prometheus
```

### Grafana Password Reset
```bash
kubectl -n monitoring exec -it deployment/grafana -- grafana-cli admin reset-admin-password newpassword
```

### Verify Service Discovery
```bash
# Check if Prometheus can see your services
kubectl -n monitoring exec -it deployment/prometheus -- wget -O- http://localhost:9090/api/v1/targets | jq
```

## Security Considerations

1. **Change default passwords immediately**
2. Consider adding:
   - OAuth/LDAP integration for Grafana
   - TLS for ingress endpoints
   - Network policies for pod communication
   - RBAC restrictions for service accounts

## Performance Tuning

For production workloads, adjust in overlays:
- Increase Prometheus retention: `--storage.tsdb.retention.time=30d`
- Adjust scrape intervals for specific jobs
- Increase resource limits based on cluster size
- Consider remote storage for long-term retention

## References
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator) (future consideration)
- [Awesome Prometheus Alerts](https://awesome-prometheus-alerts.grep.to/)
- [Grafana Best Practices](https://grafana.com/docs/grafana/latest/best-practices/)

## Support
- GitHub Issues: https://github.com/1BSmithITGuy/infutable-infra
- Internal Docs: Check XO Wiki (if configured)