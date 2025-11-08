# Grafana Dashboard Import Process (with Folder Assignment)
**Author**:  Bryan Smith  
**Date**:    11/03/2025  
**Purpose**: Grafana dashboard import process via API when UI fails

**This document explains how to import a Grafana dashboard and place it into a specific folder using the HTTP API when the UI fails.**  
- ***note***:  You can also use this process to move a dashboard to another folder when the UI fails.

---

## 1) Port-forward Grafana

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80 &
export GRAFANA_URL=http://127.0.0.1:3000
```

---

## 2) Get (or create) the target folder and capture its ID

**List existing folders:**
```bash
curl -s -u admin:YOUR_PASSWORD "$GRAFANA_URL/api/folders" \
| jq -r '.[] | {id, uid, title}'
```

**Option A — capture existing folder ID (example: `infUtable`):**
```bash
export FOLDER_ID=$(curl -s -u admin:YOUR_PASSWORD "$GRAFANA_URL/api/folders" \
| jq -r '.[] | select(.title=="infUtable") | .id')
```

**Option B — create the folder if it doesn’t exist:**
```bash
curl -s -u admin:YOUR_PASSWORD -H "Content-Type: application/json" \
  -X POST \
  -d '{"title":"infUtable"}' \
  "$GRAFANA_URL/api/folders" | tee folder.json

export FOLDER_ID=$(jq -r '.id' folder.json)
```

> Note: The built‑in **General** folder is `folderId: 0`. Custom folders have positive IDs.

---

## 3) Prepare the dashboard payload (adds `folderId` and datasource input)

Assuming your exported dashboard file is `US103-Overview-v2.json` and the Prometheus datasource in Grafana is named `prometheus`:

```bash
# Wrap the dashboard for API import and assign it to the target folder
jq --argjson fid "$FOLDER_ID" \
   '{dashboard: ., folderId: $fid, overwrite: true,
     inputs: [{
       name: "DS_PROMETHEUS",
       type: "datasource",
       pluginId: "prometheus",
       value: "prometheus"
     }]}' \
   "US103-Overview-v2.json" > US103-Overview-v2-import.json
```

---

## 4) Import via API (username/password)

```bash
curl -s -u admin:YOUR_PASSWORD \
  -H "Content-Type: application/json" \
  -X POST \
  -d @US103-Overview-v2-import.json \
  "$GRAFANA_URL/api/dashboards/import" | jq
```

**Example success response:**
```json
{
  "uid":"106a9aee-e7c8-4566-8f7f-9ded166fc0c8",
  "title":"US103-Overview v2",
  "imported":true,
  "importedUrl":"/d/106a9aee-e7c8-4566-8f7f-9ded166fc0c8/us103-overview-v2",
  "dashboardId":33,
  "folderId":2
}
```

---

## 4) Verify placement

```bash
curl -s -u admin:YOUR_PASSWORD \
  "$GRAFANA_URL/api/search?query=US103" \
| jq -r '.[] | select(.type=="dash-db") | {title, folderTitle, folderId}'
```

You should see `"folderTitle": "infUtable"` and the matching `folderId` you used.

---

## Troubleshooting

### Datasource present?
```bash
kubectl exec -n monitoring deployment/monitoring-grafana -c grafana -- \
  wget -q -O- http://localhost:3000/api/datasources \
| jq '.[] | {name, uid, type}'
```

### Grafana logs during import
```bash
kubectl logs -n monitoring deployment/monitoring-grafana -c grafana --tail=100 -f
```

### Prometheus reachable?
```bash
kubectl exec -n monitoring deployment/monitoring-grafana -c grafana -- \
  wget -q -O- \
  'http://monitoring-kube-prometheus-prometheus.monitoring:9090/api/v1/query?query=up' \
| jq '.status, (.data.result | length)'
```

---

## Notes

- The `overwrite: true` flag replaces an existing dashboard with the same UID or slug.