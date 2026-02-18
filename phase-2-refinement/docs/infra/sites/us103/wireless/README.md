# Wireless Access Point — BSUS103WAP01

Author: Bryan Smith  
Created: 2026-01-27  
Last Updated: 2026-02-18

## Revision History

| Date       | Author | Change Summary                |
|------------|--------|-------------------------------|
| 2026-01-27 | Bryan  | Initial document (phase 1)    |
| 2026-02-18 | Bryan  | Migrated to phase 2 standards |

---

## System Information

| Property | Value |
|----------|-------|
| Hostname | BSUS103WAP01 |
| Model | TP-Link EAP610 |
| Hardware Version | 3.0 |
| Firmware | 1.3.2 Build 20230414 |
| IP Address | 10.0.0.61 |
| Management VLAN | 200 |
| Location | Upstairs |
| Uplink | Port 2 on BSUS103SW0801 (PoE) |

## SSID Configuration

| SSID | Band | VLAN | Purpose |
|------|------|------|---------|
| SFLAN01 | 2.4 GHz | 6 | Primary home WiFi |
| SFLAN01 | 5 GHz | 6 | Primary home WiFi |
| SFVID01 | 2.4 GHz | 6 | Video/streaming devices |
| SFVID01 | 5 GHz | 6 | Video/streaming devices |
| SFIoT01 | 2.4 GHz | 6 | IoT devices |
| INFUS103mgt01 | 2.4 GHz | 200 | Infrastructure management |
| INFUS103mgt01 | 5 GHz | 200 | Infrastructure management |

All SSIDs use WPA-PSK security.

## Notes

- The management SSID (INFUS103mgt01) provides wireless access to VLAN 200 for laptop connectivity to infrastructure management interfaces.
- Home/IoT SSIDs (VLAN 6) are not part of the lab environment.
