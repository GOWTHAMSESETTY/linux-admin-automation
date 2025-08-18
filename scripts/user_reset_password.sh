#!/usr/bin/env bash
set -euo pipefail
if [[ $EUID -ne 0 ]]; then echo "Run with sudo"; exit 1; fi
user="${1:-}"
[[ -z "$user" ]] && { echo "Usage: sudo $0 <username>"; exit 1; }
id -u "$user" >/dev/null 2>&1 || { echo "No such user: $user"; exit 1; }
pw="$(openssl rand -base64 12)"
echo "$user:$pw" | chpasswd
chage -d 0 "$user"
echo "New password for $user: $pw"
