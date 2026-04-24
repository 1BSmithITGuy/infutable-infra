# XCP-ng (with Xen Orchestra) vs Proxmox comparison
**Author:**  Bryan Smith
**Date:** 02-08-2026  

## Summary

A comparison of Proxmox and XCP-ng with Xen Orchestra (XO).

### Interface - winner:  XCP-ng/XO

* I find the Xen Orchestra (XO) GUI to be easier to use for day to day operations and is much closer to a refined "VMware-like" experience; XO abstracts away the "Linux" underneath much better than Proxmox.
* Proxmox has a lot more in the GUI but you don't use most of it; so the end result is a busy interface.  It isn't horrible either, but I think most Systems Engineers would prefer XO's interface.
* You can't label things in Proxmox with friendly names like you can in XO.  

**NOTE:**  If you do not have XO, then managing XCP-ng becomes significantly more difficult since the interface that comes preinstalled with the host, XO-Lite, is not mature and has a lot of features that are either missing or greyed out requiring a lot of CLI work.  
* However, even a small org can find space for a small VM like XO; for a homelab with a single small host, this may be a deal breaker.

## Networking - Winner:  XCP-ng/XO

With XO:
* You can have friendly names for all the NICs.  
* You can create "networks" similar to vSwitches in VMware, and because they use Open vSwitch (OVS), it behaves like a VMware vSwitch.  
* When you connect 2 NICs to a "network", XCP-ng will balance the traffic of VMs like a VMware vSwitch would without any extra switch features/configuration (LACP).

With Proxmox: 
* You can't create friendly names for your networks like in Xen or VMware.  
* You can't have VM's on a "switch abstraction" that has 2 NICs for uplinks without either using LACP or manually installing OVS.
* From what I read, XCP-ng/Xen abstracts OVS away very well, and adding into Proxmox adds more complication and risk where it may not be worth it, so active/standby is recommended.
* You can do active/standby just fine, but it would be much nicer to be able to use both NICs which also would give you active/standby.

## Local Storage - Winner:  Proxmox (kind of)

I am using local storage without a hardware RAID controller.  Most enterprises organizations would not have prosumer hardware without a legit hardware RAID controller (Lenovo P520 workstations for me), so that is why I say "kind of" above.  

Proxmox is fully integrated with ZFS, so a ZFS RAID mirror is no problem.  I do not have a Proxmox cluster yet, but from what I have read, ZFS can do incredible things and Proxmox treats ZFS as a "first class citizen" with full integration. You can use ZFS with XCP-ng I believe, but XCP-ng and XO are not "aware"