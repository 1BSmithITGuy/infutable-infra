
## General

This directory contains a focused VMware example from an archived lab repository (see [Get-InfutableVMWInventory.ps1](Get-InfutableVMWInventory.ps1)).

The script included here was intentionally chosen because it represents a broad, environment-wide use case rather than a narrow, one-off task. It scales well, iterates across multiple layers of the vSphere inventory, constructs structured host-level objects from multiple data sources, and produces output suitable for operational review and future automation.

**This README serves two purposes:**

* To explain what the script does and why it was designed this way.
* To document why VMware is no longer the primary platform used in my lab while still demonstrating deep familiarity with vSphere and PowerCLI (see **Lab Direction and Platform Choices** section below).

---

## Get-InfutableVMWInventory.ps1

### This script generates a detailed vSphere host inventory report using data gathered and modeled from multiple sources:

* **vCenter:** PowerCLI with direct vSphere Management API view objects (`Get-View`)
* **External data sources:** CSV files and Excel spreadsheets in this lab, with the same logic easily adaptable to database-backed sources in a production environment

### What makes this script powerful is not just the data it collects, but the way it is structured

* **Engine-based design:**
  The core logic functions as an engine that traverses an entire environment efficiently. Once this traversal exists, the same structure can be reused or extended for additional reporting, troubleshooting, automation, or deeper visibility without rewriting new scripts from scratch.

* **Direct API access with Get-View:**
  By relying on `Get-View` instead of higher-level PowerCLI cmdlets (`Get-VM`, `Get-VMHost`, etc.), the script interacts more directly with the vSphere Management API. This approach is significantly faster in larger environments and allows access to more granular data than traditional cmdlets expose.

---

## Output and Data Processing

The script produces a formatted Excel workbook using `Export-Excel`, resulting in a structured Excel table with filters applied. The output is immediately usable for operational review and analysis, and the same data could just as easily be pushed into an external system such as a CMDB or NetBox.

External data sources are incorporated and processed as part of the report, including:

* **Warranty and support data:**
  Vendor or internally sourced lifecycle data such as serial numbers or service tags, support start and end dates, ship dates, and related metadata. All major hardware vendors expose this data in structured formats suitable for import/correlation.

* **Site-specific information:**
  Most organizations operating at scale maintain some method of identifying physical or logical sites across IT, networking, accounting, or facilities. This script demonstrates how that data can be incorporated into infrastructure reporting.

* **Example automation use cases:**
  The same engine used for reporting can be leveraged to drive automation. One example includes:

  * **Tagging:** Automatically tagging hosts with lifecycle, warranty, or site metadata
  * **Alerting:** Including those tags in alerts or notifications when hardware ages out of support or requires replacement

---

## Lab Direction and Platform Choices

### Why my lab no longer runs on VMware

When Broadcom acquired VMware, I chose not to continue running vSphere in my lab after my evaluation licenses expired. While I hold multiple VMware certifications and have extensive experience with the platform, I wanted to broaden my focus toward infrastructure-as-code, microservices and Kubernetes, and platform-agnostic automation rather than remain tied to a single-vendor virtualization stack.

Moving the lab to Xen/XCP-ng and Proxmox (KVM) created opportunities to work with different hypervisors, APIs, and tooling such as bash and Terraform, while expanding my exposure to alternative virtualization and operational models.

More broadly, I expect changes in VMware licensing and pricing, along with the increasing use of AI-assisted tooling, to:

* Increase competition in the virtualization market
* Accelerate development, adoption, and migration toward alternative hypervisors and microservices-based architectures.
