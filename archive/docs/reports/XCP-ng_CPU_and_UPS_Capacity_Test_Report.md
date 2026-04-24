# UPS Capacity and host CPU capacity test
**Author:**  Bryan Smith, assisted with Claude AI
**Date:** 11-12-2025  
**Environment:** XCP-ng Virtualization Lab  
**UPS Model:** CyberPower CP850AVRLCD (510W / 850VA)  

## Summary
- **Goals:**
    - ***Primary goal:***  Performed CPU stress testing on XCP-ng host (BSUS103VM02) to validate UPS capacity under peak load conditions. 
        - Both hosts are identical hardware, so I am only running on one host.  
    - ***Secondary goal:***  Test how XCP-NG would perform under load with 10 vCPUs at full capacity by measuring CPU steal.  
- **Results:**
    - Testing stressed 10 of 12 available CPU threads at 100% utilization, with all cores running at max turbo frequency (3.7GHz). 
    - Peak power draw measured 270-290W. 
    - Current UPS (510W) is adequate for single-host under load but would be marginal if both hosts ran sustained 100% CPU loads simultaneously - that is without switches needed to automate shutdown in a power loss scenario.
        - Getting CyberPower CP1000AVRLCD which would allow me to also add in switches, NVR, and miniPC host.
    - Additionally measured CPU steal (basically CPU ready in VMWare terminology) - hosts have way more capacity regarding CPU than current production.

## Test Environment

### Hardware Configuration
- **Host:** BSUS103VM02
- **CPU:** Intel Xeon W-2135 @ 3.70GHz (6 cores / 12 threads, 140W TDP)
- **Memory:** 48GB
- **Hypervisor:** XCP-ng 8.x (Xen 4.19)

### Virtual Machines Under Test
- **VM1:** BSUS103Dev02 (5 vCPUs, 4GB RAM)
- **VM2:** BSUS103Dev03 (5 vCPUs, 4GB RAM)

## Test Methodology

### Load Scenarios
1. **Baseline:** No VMs running on BSUS103VM02 for the baseline
2. **Idle VMs:** Ubuntu Dev VMs powered on host BSUS103VM02, 5 vCPUs on each, no workload
3. **Full CPU Stress:** 100% CPU utilization across all vCPUs using stress-ng

### Stress Test Configuration
```
Tool: stress-ng v0.13.12
Method: cpu --cpu-method ackermann
Workers: 5 per VM (10 total vCPUs)
Duration: 180 seconds
```

## Results

### Power Consumption
| Scenario | Power Draw (W) | Delta from Baseline |
|----------|----------------|---------------------|
| Baseline (dom0 only) | 120-130 | - |
| VMs Idle | 140-160 | +20-30W |
| **VMs Full CPU Stress** | **270-290** | **+150-170W** |

### CPU Performance Metrics
- **VM CPU Utilization:** 500% per VM (5 vCPUs × 100%)
- **Total CPU Time:** ~900 CPU-seconds per VM (near-theoretical maximum)
- **Dom0 Overhead:** 5-17% (expected for I/O scheduling)
- **CPU Ready/Steal Time:** None detected (no resource contention)

### Physical CPU Core Utilization
**10 of 12 physical threads stressed at 100%:**
- **Fully loaded threads:** CPUs 0, 2, 4, 5, 6, 7, 8, 9, 10, 11
- **Light load (dom0):** CPUs 1, 3
- **CPU Frequency:** All cores maintained 3.70 GHz (max turbo) throughout test
- **Hyperthreading:** Each vCPU consumed one full hyperthread; VMs reported actual 3.7GHz frequency

### Hypervisor Scheduling
VMs maintained consistent 500% CPU utilization throughout 180-second test window with no scheduling delays, indicating proper resource allocation for the current vCPU:pCPU ratio (10 vCPUs : 12 threads).

## Capacity Analysis

### UPS Specifications vs. Measured Load
- **UPS Capacity:** 510W / 850VA
- **Peak Measured Load:** 290W (single host, 10/12 threads at 100%)
- **Estimated Dual-Host Peak:** ~580W (both hosts at 100% CPU)
- **Single-host Safety Margin:** 220W (43%)
- **Dual-host Scenario:** Would exceed capacity by ~70W

### Projected Scenarios
| Configuration | Estimated Load | UPS % Utilized | Status |
|---------------|----------------|----------------|--------|
| Both hosts idle VMs | ~180W | 35% | OK |
| Single host stressed | ~290W | 57% | OK |
| Both hosts stressed | ~580W | 114% | EXCEEDS |

**Note:** Dual-host 100% CPU stress is unlikely in normal operations. Realistic mixed workloads would stay under 510W capacity.

## Conclusions

1. **UPS is adequately sized for realistic workloads** - Single-host stress shows 43% headroom at 290W
2. **Dual-host 100% CPU stress would exceed capacity** - Estimated 580W vs 510W limit (114% utilization)
3. **No CPU over-subscription issues** - Hypervisor scheduling performing optimally with zero steal time
4. **All cores ran at max turbo (3.7GHz)** - No thermal throttling observed during sustained 3-minute load
5. **Hyperthreading working as expected** - Each vCPU consumed one full hyperthread

## Recommendations

- **For $10 upgrade to CP1000AVRLCD (600W)** - Eliminates dual-host stress risk and provides better headroom
- Current UPS (CP850AVRLCD) is acceptable if simultaneous dual-host CPU stress is unlikely
- Dom0 allocation (4 vCPUs) is optimal - do not adjust
- Current vCPU allocation (5 per VM) is appropriate for 12-thread system
- Consider monitoring power draw during disk-intensive workloads (not tested in this scenario)

---
*Test performed via automated stress-ng workload with real-time hypervisor monitoring*
