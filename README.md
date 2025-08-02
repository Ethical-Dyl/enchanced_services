<!--

 _____                                                                 _____ 
( ___ )                                                               ( ___ )
 |   |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|   | 
 |   |          ▓█████▄  ██▓ ██▓     ██▓   ▓██   ██▓                   |   | 
 |   |          ▒██▀ ██▌▓██▒▓██▒    ▓██▒    ▒██  ██▒                   |   | 
 |   |          ░██   █▌▒██▒▒██░    ▒██░     ▒██ ██░                   |   | 
 |   |          ░▓█▄   ▌░██░▒██░    ▒██░     ░ ▐██▓░                   |   | 
 |   |          ░▒████▓ ░██░░██████▒░██████▒ ░ ██▒▓░                   |   | 
 |   |           ▒▒▓  ▒ ░▓  ░ ▒░▓  ░░ ▒░▓  ░  ██▒▒▒                    |   | 
 |   |           ░ ▒  ▒  ▒ ░░ ░ ▒  ░░ ░ ▒  ░▓██ ░▒░                    |   | 
 |   |           ░ ░  ░  ▒ ░  ░ ░     ░ ░   ▒ ▒ ░░                     |   | 
 |   |             ░     ░      ░  ░    ░  ░░ ░                        |   | 
 |   |           ░                          ░ ░                        |   | 
 |   |  ██▓███   ▄▄▄     ▓██   ██▓ ███▄    █ ▄▄▄█████▓▓█████  ██▀███   |   | 
 |   | ▓██░  ██▒▒████▄    ▒██  ██▒ ██ ▀█   █ ▓  ██▒ ▓▒▓█   ▀ ▓██ ▒ ██▒ |   | 
 |   | ▓██░ ██▓▒▒██  ▀█▄   ▒██ ██░▓██  ▀█ ██▒▒ ▓██░ ▒░▒███   ▓██ ░▄█ ▒ |   | 
 |   | ▒██▄█▓▒ ▒░██▄▄▄▄██  ░ ▐██▓░▓██▒  ▐▌██▒░ ▓██▓ ░ ▒▓█  ▄ ▒██▀▀█▄   |   | 
 |   | ▒██▒ ░  ░ ▓█   ▓██▒ ░ ██▒▓░▒██░   ▓██░  ▒██▒ ░ ░▒████▒░██▓ ▒██▒ |   | 
 |   | ▒▓▒░ ░  ░ ▒▒   ▓▒█░  ██▒▒▒ ░ ▒░   ▒ ▒   ▒ ░░   ░░ ▒░ ░░ ▒▓ ░▒▓░ |   | 
 |   | ░▒ ░       ▒   ▒▒ ░▓██ ░▒░ ░ ░░   ░ ▒░    ░     ░ ░  ░  ░▒ ░ ▒░ |   | 
 |   | ░░         ░   ▒   ▒ ▒ ░░     ░   ░ ░   ░         ░     ░░   ░  |   | 
 |   |                ░  ░░ ░              ░             ░  ░   ░      |   | 
 |   |                    ░ ░                                          |   | 
 |___|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|___| 
(_____)                                                               (_____)
  Welcome to **Enhanced Services** — your centralized toolkit for
  Windows system health checks and vulnerability auditing.
-->

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)](https://docs.microsoft.com/powershell)

---

## 🛠️ Enhanced Services Overview

The **Enhanced Services** repository brings together two complementary modules:

1. **System Health Check** (`health_check`)

   * A PowerShell toolkit that gathers OS info, update history, disk usage, services status, installed applications, event logs, CPU/memory stats, network configuration, Defender health, reboot flags, and more.
   * Outputs **JSON** and a styled **HTML** report.
   * Detailed instructions and customization options live in `health_check/docs/README.md`.

## 🗂️ Repository Structure

```bash
enhanced_services/            # Root folder
├── health_check/             # System Health Check module
│   ├── HealthCheck.ps1       # Main health-check script
│   └── docs/                 # In-depth documentation
│       └── README.md         # Script guide and customization
│
├── LICENSE                   # MIT License
└── README.md                 # ← You are here
```

## 🚀 Quick Links

* 🔍 [Health Check Docs and Video](./health_check/HEALTH_CHECK_README.md)
* ⚙️ [Run Health Check](./health_check/health_check.ps1)

## 🚀 Getting Started

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-org/enhanced_services.git
   cd enhanced_services
   ```

2. **System Health Check**

   * Navigate to `health_check/`
   * Ensure PowerShell is run **as Administrator**
   * Execute:

     ```powershell
     .\HealthCheck.ps1
     ```


## ✨ Features

* **Comprehensive Health Metrics**: OS, updates, storage, services, logs, performance, network, Defender, and reboot status.
* **Dual Output**: Machine-readable JSON and polished HTML for health checks; text/CSV summaries.
* **Modular Design**: Use independently or together in automated pipelines.

## 🤝 Contributing

I welcome contributions.

1. Fork the repo.
2. Create a branch (`git checkout -b feat/my-feature`).
3. Commit your changes (`git commit -m "Add awesome feature"`).
4. Push (`git push origin feat/my-feature`).
5. Open a Pull Request.

## 📜 License

Distributed under the MIT License. See [LICENSE](./LICENSE) for details.

---

**Dyl.**
