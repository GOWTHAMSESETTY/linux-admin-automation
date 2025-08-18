#!/usr/bin/env bash
set -euo pipefail
if [[ $EUID -ne 0 ]]; then echo "Run with sudo"; exit 1; fi
user="${1:-}"
[[ -z "$user" ]] && { echo "Usage: sudo $0 <username>"; exit 1; }
id -u "$user" >/dev/null 2>&1 || { echo "No such user: $user"; exit 1; }
BACKUP_DIR="/opt/linux-admin-automation/output/home_backups"
mkdir -p "$BACKUP_DIR"
if getent passwd "$user" >/dev/null; then
  home_dir="$(getent passwd "$user" | cut -d: -f6)"
  if [[ -d "$home_dir" ]]; then
    tar czf "$BACKUP_DIR/${user}_home_$(date +%F_%H%M%S).tar.gz" -C "$home_dir" .
  fi
  userdel -r "$user" || true
  echo "Deleted user: $user. Backup stored in $BACKUP_DIR"
fi
