# Windows 10/11 System Health Check

A PowerShell script that gathers comprehensive system health information and outputs both JSON and a styled HTML report.

## Synopsis

```powershell
.\healthCheck.ps1
```

Run as Administrator to produce a timestamped JSON and HTML file in the same folder as the script.

## Description

This script collects:

* **System Info**: OS version, last boot time, uptime
* **Windows Updates**: History of recent updates (up to last 50) and installed hotfixes
* **Disk & Volume**: Drive letters, file systems, remaining and total space (in GB)
* **Services**: Name, display name, status, and start type for all services
* **Installed Applications**: Both 64-bit and 32-bit programs from registry uninstall keys
* **Event Logs**: Errors and warnings from System & Application logs (last 24 hours)
* **CPU & Memory**: Processor details and free/total physical memory (in MB)
* **Network**: Enabled adapters, link speed, MAC, and IPv4 addresses
* **Windows Defender**: Product version, real-time protection, last scan times
* **Pending Reboot**: Flag if the system requires a restart
* **Optional**: Firewall summary (commented out by default)

It outputs:

1. **JSON** (`HealthCheck_<COMPUTERNAME>_<timestamp>.json`)
2. **HTML** (`HealthCheck_<COMPUTERNAME>_<timestamp>.html`) — a sectioned, styled report

## Prerequisites

* **Windows PowerShell 5.1** (built-in on Windows 10/11) or later
* **Administrator rights** (the script will exit if not elevated)
* **Internet access** for first-time installation of the PSWindowsUpdate module

## Installation

1. Save the script as `HealthCheck.ps1` in a folder of your choice.
2. Right-click the PowerShell icon and select **Run as Administrator**.

   > On first run, the script will auto-install the **PSWindowsUpdate** module under your user scope.

## Usage

```powershell
# From an elevated PowerShell prompt, navigate to the script folder:
cd C:\Path\To\Script

# Run the script:
.\HealthCheck.ps1

# Sample output:
# ✅ Reports generated:
#     JSON: C:\Path\To\Script\HealthCheck_MYPC_20250802_142530.json
#     HTML: C:\Path\To\Script\HealthCheck_MYPC_20250802_142530.html
```

## Demo Video



https://github.com/user-attachments/assets/bb235880-2344-46c7-9c4f-92a54c127d61



## Output Files

* **JSON**
  A machine-readable object with nested sections for each data category. Useful for ingestion into other tools or automated dashboards.

* **HTML**
  A human-friendly report with:

  * A custom CSS style (inline)
  * Section headings (`<h2>…</h2>`)
  * Tables for each data set
  * A prominent “Pending Reboot?” flag

Open the HTML in any modern browser.

## Customization

* **Firewall Summary**
  The script can be extended by adding a call to `Get-NetFirewallProfile` or similar within the data-gathering section and including it in the `$report` object and HTML.

* **Styling**
  Modify the `$css` block near the bottom of the script to adjust fonts, colors, or table appearance.

* **Report Depth**
  Change `ConvertTo-Json -Depth 5` to a higher value if you add deeper nested objects.

## Notes

* The script uses registry keys to detect pending reboot states under:

  * `HKLM:\…\Component Based Servicing\RebootPending`
  * `HKLM:\…\Session Manager\PendingFileRenameOperations`
  * `HKLM:\…\WindowsUpdate\Auto Update\RebootRequired`

* Only the **last 50** Windows Update entries are shown in HTML; JSON contains the full history.

* Designed for **Windows 10/11**; some CIM classes or cmdlets may differ on older OS versions.

## Author & License

**Author:** Dylan Paynter
**License:** MIT
---

> **Tip:** Add this script to scheduled tasks if you need regular automated health checks.
