# Monitoring Stack

Multi-cluster monitoring using Prometheus and Grafana deployed via Helm.

## Architecture

- **Primary Cluster** (us103-kubeadm01): Runs full monitoring stack
- **Secondary Cluster** (us103-k3s01): Runs exporters only
- **Components**: Prometheus, Grafana, Node Exporter, kube-state-metrics, AlertManager

## Deployment

### Primary Stack
```bash
cd k8s/platform/monitoring
./deploy.sh
```

### External Cluster Monitoring (/external-monitoring)
```bash
./deploy-node-exporter.sh      # Hardware metrics
./deploy-kube-state-metrics.sh  # Kubernetes object metrics
```

## Access

**URL**: http://grafana.us103kubeadm01.infutable.com  
**Username**: admin  
**Password**: 
```bash
kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d
```

## Configuration

All configuration is in `prometheus-values.yaml`. Key settings:
- Data retention: 15 days
- Storage: 10GB per component
- External targets: K3s cluster metrics via NodePort

### Reference Documentation
- [Chart Values Reference](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Configuration Options](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)

## Dashboards

### Pre-configured
- **315**: Kubernetes Cluster Monitoring (multi-cluster view)
- **1860**: Node Exporter Full (hardware metrics)
- **6417**: Kubernetes Cluster Resources

### Custom Dashboards
To import, go to **Dashboards**, select **import**, and browse to the JSON file.
- `dashboards/US103-Overview.json`: Combined view of all nodes across clusters


## Operations

### Adding External Targets

To monitor infrastructure outside Kubernetes, add static targets to `prometheus-values.yaml`:

```yaml
prometheus:
  prometheusSpec:
    additionalScrapeConfigs:
    - job_name: 'external-service'
      static_configs:
      - targets: ['hostname:port']
```

### Update Configuration
```bash
helm upgrade monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring -f prometheus-values.yaml
```

### Complete Removal
```bash
helm uninstall monitoring -n monitoring
kubectl delete pvc -n monitoring --all
kubectl delete namespace monitoring
```

## Labels Strategy

Consistent labels across all metrics for filtering:
- `cluster`: Cluster identifier (us103-kubeadm01, us103-k3s01)
- `site_code`: Physical location (us103)
- `provider`: Infrastructure provider (on-prem, aws, azure)
- `node_type`: Node role (master, worker)

## Files

- `prometheus-values.yaml`: Production configuration
- `deploy.sh`: Deployment script
- `external-monitoring/`: Scripts for external cluster setup
- `manual-deployment/`: Learning exercise - raw Kubernetes manifests (not for production)


## Troubleshooting

**Check Prometheus targets:**
```bash
kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090
# Open http://localhost:9090/targets
```

**View Grafana logs:**
```bash
kubectl logs -n monitoring deployment/monitoring-grafana | grep -i dashboard
```

**Common Issues:**
- N/A values in dashboards: Check Prometheus targets page for failed scrapes
- Dashboard provisioning errors: Folder name conflicts - import manually instead
- Connection refused errors: Normal for kube-controller-manager, kube-scheduler, etcd

