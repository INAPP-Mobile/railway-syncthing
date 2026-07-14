<div align="center">
  <img src="https://raw.githubusercontent.com/INAPP-Mobile/railway-syncthing/main/template-icon.svg" alt="Syncthing" width="300" height="82">
  <h1 align="center">Syncthing</h1>
  <p align="center">Continuous file synchronization — private, secure, decentralized.</p>
</div>

<p align="center">
  <a href="https://railway.com/deploy/syncthing-2"><img src="https://img.shields.io/badge/Deploy%20on-Railway-%236C3FC5?style=for-the-badge&logo=railway&logoColor=white" alt="Deploy on Railway"></a>
  <a href="https://github.com/syncthing/syncthing"><img src="https://img.shields.io/github/stars/syncthing/syncthing?style=for-the-badge&logo=github&label=GitHub" alt="GitHub Stars"></a>
  <a href="https://github.com/syncthing/syncthing/blob/main/LICENSE"><img src="https://img.shields.io/github/license/syncthing/syncthing?style=for-the-badge" alt="License"></a>
</p>

<div align="center">
  <img src="https://raw.githubusercontent.com/INAPP-Mobile/railway-syncthing/main/og-image.svg" alt="Syncthing Deploy on Railway" width="600">
</div>

---

## ✨ Features

- **Real-Time Sync** — Files are synchronized continuously as they change, with no polling or manual triggers
- **End-to-End Encrypted** — All traffic is secured with TLS and perfect forward secrecy — no third party ever sees your data
- **Decentralized** — No central server. Your data stays on your devices, communicating peer-to-peer
- **Cross-Platform** — Windows, macOS, Linux, FreeBSD, Docker, NAS appliances, Android, and iOS (third-party)
- **Web UI** — Full-featured management interface accessible from any browser
- **Conflict Handling** — Intelligent conflict detection and resolution with version history
- **Bandwidth Control** — Per-folder and per-device rate limiting, scheduling, and traffic management
- **Discovery** — Automatic LAN and WAN discovery via global and local discovery servers
- **Open Source** — MPL-2.0 licensed, 85K+ GitHub stars, battle-tested for over 12 years

## 🚀 Deploy on Railway

### One-Click Deploy

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/syncthing-2)

Click the button above to deploy Syncthing instantly on Railway.

### Prerequisites

- A [Railway](https://railway.com) account

## ⚙️ Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PORT` | No | `8384` (set by Railway) | Web UI listen port. Railway injects this automatically; the entrypoint maps it to Syncthing's GUI address. |
| `PUID` | No | `1000` | User ID for file ownership (only used when running as root) |
| `PGID` | No | `1000` | Group ID for file ownership (only used when running as root) |
| `STGUIADDRESS` | No | `0.0.0.0:${PORT}` | Override the GUI listen address (format: `<host>:<port>`) |
| `STHOMEDIR` | No | `/var/syncthing/config` | Syncthing config directory |
| `UMASK` | No | — | File creation umask (e.g., `002` for group-writable folders) |

### 🔒 Security Note

Syncthing listens on `0.0.0.0:PORT` by default so Railway's health checks and public routing work. **Set a GUI password immediately after first login** — the Web UI has no default authentication. Go to **Actions → Settings → GUI Authentication** to configure a username and password.

## 📡 Service Topology

```
┌────────────────────────────────────────────────────────────┐
│                     Syncthing Container                      │
│                                                              │
│  ┌────────────┐  ┌──────────────┐  ┌───────────────────┐   │
│  │  Web UI    │  │  Sync Engine │  │  Discovery        │   │
│  │  :8384/PORT│  │  :22000      │  │  :21027/udp       │   │
│  │  REST API  │  │  TCP+UDP     │  │  (global+LAN)     │   │
│  └────────────┘  └──────────────┘  └───────────────────┘   │
│        │                │                                     │
│        │           ┌────┴────┐                                │
│        │           │         │                                 │
│   ┌────┴────┐  ┌──┴──┐  ┌───┴────┐                           │
│   │ Browser │  │ Dev │  │ Remote │                           │
│   │  (Web)  │  │  A  │  │  Dev B │                           │
│   └─────────┘  └─────┘  └────────┘                           │
│                                                              │
│  Storage: /var/syncthing (ephemeral on Railway)              │
│  ┌────────────────────────────────────────┐                  │
│  │  config/  (STHOMEDIR)                   │                  │
│  │  Sync/    (default sync folder)         │                  │
│  └────────────────────────────────────────┘                  │
└────────────────────────────────────────────────────────────┘
```

## 💻 Local Development

### Prerequisites

- Docker installed on your machine

### Quick Start

```bash
# Clone the repository
git clone https://github.com/INAPP-Mobile/railway-syncthing.git
cd railway-syncthing

# Build and run with Docker
docker build -t syncthing-railway .
docker run -d \
  --name syncthing \
  -p 8384:8384 \
  -p 22000:22000 \
  -p 22000:22000/udp \
  -p 21027:21027/udp \
  -e PORT=8384 \
  -v syncthing-data:/var/syncthing \
  syncthing-railway

# Open the Web UI
open http://localhost:8384
```

### Using Docker Compose

```yaml
services:
  syncthing:
    build: .
    ports:
      - "8384:8384"
      - "22000:22000"
      - "22000:22000/udp"
      - "21027:21027/udp"
    environment:
      - PORT=8384
      - PUID=1000
      - PGID=1000
    volumes:
      - syncthing-data:/var/syncthing
    healthcheck:
      test: ["CMD", "curl", "-fkLsS", "-m", "2", "http://127.0.0.1:8384/rest/noauth/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 15s

volumes:
  syncthing-data:
```

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| **Health check failing** | Ensure `PORT` env var is set correctly. Railway sets it automatically. The health check hits `/rest/noauth/health` on the Web UI port. |
| **Cannot access Web UI** | Verify the Railway domain is correct. Check logs for startup errors. The GUI listens on `0.0.0.0:PORT`. |
| **Devices can't connect** | Syncthing uses port 22000 (TCP+UDP) for sync traffic. On Railway, only the port in `PORT` is publicly routed. Other devices connect outbound from Syncthing to your devices, or via relay discovery. Configure your devices to use relay connections or ensure they can reach each other directly. |
| **Slow sync speeds** | Railway's network topology may prevent direct peer-to-peer connections. Syncthing will automatically fall back to relay connections, which are slower. For best performance, connect devices on the same LAN. |
| **Data loss on restart** | Railway provides ephemeral storage. Data persists within the service's filesystem but is not replicated. For important data, set up syncing to a secondary device as backup. |
| **Default folder not created** | Set `STFLAGS=--no-default-folder` in env vars if you want to configure folders from scratch in the Web UI. |

## 📚 Resources

- **[Syncthing Documentation](https://docs.syncthing.net)** — Official docs
- **[Getting Started Guide](https://docs.syncthing.net/intro/getting-started.html)** — First-time setup walkthrough
- **[Syncthing Forum](https://forum.syncthing.net)** — Community support
- **[GitHub Repository](https://github.com/syncthing/syncthing)** — Source code & issues
- **[Security Page](https://syncthing.net/security.html)** — Security model details

## 📄 License

This template deploys [Syncthing](https://github.com/syncthing/syncthing), which is licensed under the **MPL-2.0 License**. See the [LICENSE](https://github.com/syncthing/syncthing/blob/main/LICENSE) file for details.

---

# Deploy and Host

## About Hosting

This template deploys **Syncthing 2.1.1** on Railway using the official Docker image. It provides a self-hosted, private file synchronization server with a browser-based management interface. The deployment maps Railway's `PORT` environment variable directly to Syncthing's web UI port, ensuring seamless platform health checks and public routing.

## Why Deploy

Self-hosting Syncthing gives you full control over your file synchronization infrastructure. Unlike cloud-based file sync services, Syncthing stores your data exclusively on your own devices — there is no central server, no third-party storage, and no data egress fees. You decide where your files live, who can access them, and how they are transmitted. This is ideal for privacy-conscious individuals, small teams, and organizations that need secure, auditable file synchronization without relying on external providers.

## Common Use Cases

- **Private Cloud Sync** — Replace Dropbox, Google Drive, or OneDrive with a self-hosted, zero-knowledge alternative
- **Team Collaboration** — Synchronize project files across team members' devices without a central server
- **Server Backup** — Automatically sync backups from one server to another for disaster recovery
- **Media Library** — Keep media collections in sync between a home server and remote devices
- **Configuration Management** — Distribute configuration files across multiple machines

## Dependencies for Syncthing

### Deployment Dependencies

- **Railway Account** — A free Railway account with sufficient service quota
- **No External Databases** — Syncthing is self-contained with no external dependencies
- **Ephemeral Storage** — Railway provides service-level filesystem storage; no persistent volume plugin is required

---

<p align="center">
  <sub>Built by <a href="https://github.com/INAPP-Mobile">INAPP-Mobile</a> — Deploy your own private file sync in minutes.</sub>
</p>
