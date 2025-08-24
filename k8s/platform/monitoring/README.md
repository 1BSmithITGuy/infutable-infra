# Monitoring Stack

Enterprise monitoring using Prometheus and Grafana via kube-prometheus-stack Helm chart.

## Quick Deploy

```bash
cd k8s/platform/monitoring
./deploy.sh
```

## Architecture

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards  
- **Node Exporter**: Host-level metrics (CPU, RAM, disk)
- **kube-state-metrics**: Kubernetes object metrics
- **AlertManager**: Alert routing (configured but not active)

## Access

- **URL**: http://grafana.us103kubeadm01.infutable.com
- **Username**: admin
- **Password**: Auto-generated, retrieve with:
  ```bash
  kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d
  ```

## Included Dashboards

Pre-configured dashboards available in Grafana:
- Kubernetes Cluster Overview
- Node Exporter Full
- Pod/Container metrics
- Persistent Volume usage

## Configuration

Edit `prometheus-values.yaml` to modify:
- Retention period (default: 15d)
- Storage size (default: 10Gi)
- Ingress settings
- Additional scrape targets

## Adding External Targets

To monitor infrastructure outside Kubernetes, add static targets to `prometheus-values.yaml`:

```yaml
prometheus:
  prometheusSpec:
    additionalScrapeConfigs:
    - job_name: 'external-service'
      static_configs:
      - targets: ['hostname:port']
```

See `prometheus-values-multi-site.yaml` for examples.

## Maintenance

```bash
# Upgrade configuration
helm upgrade monitoring prometheus-community/kube-prometheus-stack -n monitoring -f prometheus-values.yaml

# View current values
helm get values monitoring -n monitoring

# Uninstall
helm uninstall monitoring -n monitoring
kubectl delete namespace monitoring
```

## Manual Deployment

See `manual-deployment/` for educational deployment without Helm. Not for production use.