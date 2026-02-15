# Xen Orchestra & XCP-ng Update Runbook

> **Audience:** Admins who already understand Xen Orchestra (XO) and XCP-ng.  
> If any step is unclear, review the architecture and CLI docs:  
> https://docs.xen-orchestra.com/architecture#xo-cli-cli

---

## Overview

**Recommended order:**

1. **Backups & snapshots**
2. **Update Xen Orchestra (XO)**
3. **Update XCP-ng hosts**
4. **Update VM guest tools / management agents**

```
Backup & Snapshot → Update XO → Reboot XO → Update Hosts (evacuate→patch→reboot) → Update VM Tools
```

**Expected impact:**  
- XO update: brief management-plane interruption.  
- Host updates: VM migrations/restarts depending on pool capacity. Plan a maintenance window.

---

## Pre‑flight Checklist

- [ ] XO configuration backup completed and exported (off-box)
- [ ] Pool metadata/host config backups completed
- [ ] Recent **VM backups** verified (at least last success timestamp)
- [ ] XO VM **snapshot** created (named with date/time)
- [ ] Maintenance window approved and change ticket created (if applicable)
- [ ] Admin access to XO (SSH and UI)
- [ ] Admin access to hosts (SSH)

---

## 1) Backups & Snapshots

### A. XO & Host Config
- In **XO GUI** run the job: **`TruNas_Scheduled-XO: XO_XCP-NG_Config`**
- Additionally, back up hosts via **`xsconsole`** (host-level config export)

### B. VM Backups
- Run/verify your regular XO VM backup jobs and ensure latest run succeeded.

### C. XO VM Snapshot
- Create a clean snapshot of the XO VM named like `xo-preupdate-YYYYMMDD-HHMM`

---

## 2) Update Xen Orchestra (built from sources)

> If you **use the official XO Appliance**, update from the XO UI (Settings → Updates).  
> The steps below are for **XO built from sources**.

1. SSH to the **XO VM**.
2. Run the installer/updater, then choose **`2) Update`** when prompted:
   ```bash
   sudo /opt/xo-install.sh
   ```
3. Watch for success messages; resolve any dependency errors if shown.
4. When finished, validate XO services and version:
   - Log in to the **XO UI** and check the displayed version/build.
   - Optionally on the VM:
     ```bash
     sudo systemctl status xo-server || true
     ```

> **Note:** Some environments label this script differently. If `/opt/xo-install.sh` doesn’t exist, locate your local installer path (for example under `/opt/xo/`)

---

## 3) Update XCP‑ng Hosts

> Perform **after XO has been updated**

### A. Using XO (recommended)
1. In **XO UI → Hosts**, update hosts one at a time:
   - **Evacuate** workloads from the target host (migrate VMs off).
   - **Install patches** from the host’s **Patches/Updates** tab.
   - **Reboot** the host when prompted.
2. Repeat for each host until all are patched and rebooted.

### B. CLI (dom0) reference (if needed)
If you must patch from the host shell (not typical when XO is available):
```bash
# On each host (dom0)
sudo yum clean all
sudo yum update -y
sudo reboot
```
> Use `dnf` if your XCP-ng release has switched from yum to dnf. Prefer XO’s patch workflow for pool-aware evacuations.

---

## 4) Update VM Guest Tools / Management Agents

- Mount **`guest-tools.iso`** from XO for each VM and run the installer.
  - After host updates, the **tools ISO** should be current.
- **Windows alternative:** Citrix Xen management agents (if XO tools don’t work in your environment):  
  https://www.xenserver.com/downloads

### Additional notes (Windows)
```powershell
msiexec.exe /package managementagentx64.msi /quiet /norestart
```

> Reboot VMs if requested by the installer. Verify “Management Agent”/“Guest Tools” are **Up to date** in XO.

---

## Post‑Update Validation

- **XO UI** loads and shows the expected version/build.
- **Pool health:** No red alerts; all hosts connected; time in sync.
- **VM state:** All production VMs running where expected.
- **Backups:** Trigger a small test backup job to confirm nothing broke.
- **Guest tools:** Spot-check a few Windows and Linux VMs—status “Up to date”.

---

## Rollback Strategy

- **XO failure after update:** Revert the **XO VM snapshot** created earlier.
- **Host issues after patching:** Consider reverting the specific host via known-good state, or contact support/community with logs.
- **VM agent problems:** Uninstall/reinstall tools; try the alternate agent package linked above.

> Delete snapshots after at least 3 business days. 

---

## Adjust XO VM Memory via `xe`

1. SSH to the **XCP-ng host** running the XO VM.
2. Find the XO VM **UUID**:
   ```bash
   xe vm-list name-label=<Your_XO_VM_Name> params=uuid --minimal
   # or simply: xe vm-list
   ```
3. Set memory limits (example: 3 GiB fixed, with 1 GiB static-min):
   ```bash
   xe vm-memory-limits-set uuid=<UUID> \
     static-min=1GiB dynamic-min=3GiB dynamic-max=3GiB static-max=3GiB
   ```
4. Reboot the XO VM if needed for the new limits to take effect.

---

## Changelog

- **2025-08-14:** Initial version consolidated from working notes (backups → XO → hosts → VM agents) with verification/rollback.
