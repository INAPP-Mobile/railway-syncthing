# ── Syncthing — Continuous File Synchronization ─────────────────────────────
#   Official upstream: syncthing/syncthing  (MPL-2.0)
#   Railway template:  https://github.com/INAPP-Mobile/railway-syncthing
#
#   We use the official image directly — just pin the version and wire up
#   Railway's PORT variable so platform health checks and routing work
#   without extra proxies.
# ────────────────────────────────────────────────────────────────────────────

FROM syncthing/syncthing:2.1.1

LABEL org.opencontainers.image.source="https://github.com/INAPP-Mobile/railway-syncthing"
LABEL org.opencontainers.image.description="Syncthing — continuous file synchronization. Railway template."
LABEL org.opencontainers.image.licenses="MPL-2.0"

# ── Custom entrypoint ───────────────────────────────────────────────────────
#   The upstream entrypoint (/bin/entrypoint.sh) handles PUID/PGID, UMASK,
#   PCAP, and su-exec.  Our wrapper simply maps STGUIADDRESS to Railway's
#   PORT variable so the web UI is reachable at the correct port.
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh

# ── Ports ───────────────────────────────────────────────────────────────────
#   8384    Web UI  (mapped to Railway PORT via entrypoint)
#   22000   Sync    (TCP + UDP)
#   21027   Discovery (UDP)
EXPOSE 8384 22000 22000/udp 21027/udp

# ── Health check ────────────────────────────────────────────────────────────
#   Shell-form CMD so ${PORT} expands correctly at runtime.
#   Railway's platform probe hits the same endpoint by setting PORT.
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -fkLsS -m 2 "http://127.0.0.1:${PORT:-8384}/rest/noauth/health" | grep -o OK || exit 1

# ── Runtime ─────────────────────────────────────────────────────────────────
#   We do NOT hard-code USER here.  The upstream entrypoint handles both
#   root and non-root environments:
#     - root (native Docker):  chown + su-exec to PUID:PGID
#     - non-root (Railway):    exec through (datadir must be writable)
#   Our wrapper chmods the data directory before delegating so non-root
#   Railway containers can write config and keys.

ENTRYPOINT ["/docker-entrypoint.sh"]
