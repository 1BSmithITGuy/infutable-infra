# 08-27-2025
Finish monitoring:
	- Add some pod metrics into the main dashboard, 
	- Readme.md in dashboard explaining how I created the dashboard off of node exporter full
	- 
	- Create readme.md for 
	- Add in xcp-ng, opnsense, adds, 
	- Redo externalmonitoring directory and scripts into one.
	- Redo readme.md - make sure website for documentation is in there, 08-25 notes definitely have documentation stuff, 
    - Merge dev into main
## Yesterday

### Documentation:  questions and add
remove grafana/prom - do i need to remove the PVC before the namespace?  Add this to the documentation also (note:  k is an alias for kubectl, so replace the alias please)

```bash
helm uninstall -n monitoring monitoring
k delete pvc -n monitoring --all
k delete namespaces monitoring

```

to make changes:
```bash
helm upgrade monitoring prometheus-community/kube-prometheus-stack -n monitoring -f prometheus-values.yaml
```

Check logs:
```bash
kubectl logs -n monitoring deployment/monitoring-grafana | grep -i dashboard
```
---
 troubleshoot prometheus\grafana dashboards showing NA:
 ```bash
kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090
# then open http://localhost:9090/targets
```

## Notes

