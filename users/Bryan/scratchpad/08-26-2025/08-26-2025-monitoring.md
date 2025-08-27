# 08-26-2025





## Inbox

## Notes

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

![alt text](_img/image-1.png)

On my external cluster running node-exporter (k3s - node http://bsus103km01:30911 in screenshot above), this is the result:

─[bryan@bsus103jump01:{us103-k3s01}]─[/srv/repos/infutable-infra/k8s]
└──╼ $k get pods -n monitoring | grep kube-state
kube-state-metrics-7c64d947d4-888jh            0/1     Pending   0          46h
-  I uncordoned this node and it is running now.  down status is resolved in screenshot above for node http://bsus103km01:30911.  


─[bryan@bsus103jump01:{us103-kubeadm01}]─[/srv/repos/infutable-infra/k8s]
└──╼ $k get pods -n monitoring | grep kube-state
monitoring-kube-state-metrics-69dcd947d6-qfw7j           1/1     Running   1 (7h7m ago)   21h

