#!/bin/sh
# ── Syncthing Railway entrypoint wrapper ────────────────────────────────────
#   The official upstream entrypoint (/bin/entrypoint.sh) is responsible for
#   PUID/PGID, UMASK, and PCAP handling.  This wrapper does two things:
#
#   1. Make /var/syncthing writable for non-root Railway containers that
#      can't use the upstream su-exec dance.
#   2. Map Railway's PORT variable to STGUIADDRESS so the platform health
#      check and public routing reach the Syncthing web UI at the correct
#      port — zero proxies, zero overhead.
#
#   Railway injects $PORT at runtime (e.g. 8080).  Syncthing's web UI is
#   normally on 8384.  Instead of adding a proxy (socat, nginx, etc.) we
#   simply tell Syncthing to listen on whatever port Railway assigned.
# ────────────────────────────────────────────────────────────────────────────

set -eu

# Ensure the data directory is writable in non-root environments (Railway).
mkdir -p /var/syncthing/config
chmod 777 /var/syncthing /var/syncthing/config

# Map Railway's PORT to Syncthing's GUI address.
# Upstream default is 0.0.0.0:8384 — we keep the same bind address but use PORT.
# If PORT is unset (non-Railway environments) we fall back to 8384.
STGUIADDRESS="0.0.0.0:${PORT:-8384}"
export STGUIADDRESS

# Delegate to the official upstream entrypoint.
exec /bin/entrypoint.sh /bin/syncthing
