#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="/opt/linux-admin-automation"
LOG_DIR="$PROJECT_ROOT/logs"
OUT_DIR="$PROJECT_ROOT/output"
CSV_FILE="${1:-$PROJECT_ROOT/data/users.csv}"
LOG_FILE="$LOG_DIR/user_mgmt.log"
DATE_TAG="$(date +%Y%m%d)"
CREDS_FILE="$OUT_DIR/credentials_${DATE_TAG}.csv"

mkdir -p "$LOG_DIR" "$OUT_DIR"

log() {
  echo "$(date '+%F %T') | $*" | tee -a "$LOG_FILE" >/dev/null
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must run as root. Try: sudo $0 $CSV_FILE"
    exit 1
  fi
}

valid_username() {
  # POSIX-ish: start letter or _, then letters/numbers/._-
  [[ "$1" =~ ^[a-z_][a-z0-9._-]*$ ]]
}

create_group_if_needed() {
  local g="$1"
  if [[ -z "$g" ]]; then return 0; fi
  if getent group "$g" >/dev/null; then
    log "Group exists: $g"
  else
    log "Creating group: $g"
    groupadd "$g"
  fi
}

create_user() {
  local username="$1" fullname="$2" groups="$3" shell="$4"

  if id -u "$username" >/dev/null 2>&1; then
    log "User exists, skipping: $username"
    return 2
  fi

  local shell_to_use="${shell:-/bin/bash}"

  # Ensure all groups exist first
  IFS=',' read -ra glist <<< "${groups:-}"
  for g in "${glist[@]}"; do
    [[ -n "${g:-}" ]] && create_group_if_needed "$g"
  done

  local extra_groups=""
  if [[ -n "${groups:-}" ]]; then
    extra_groups="-G ${groups}"
  fi

  log "Creating user: $username | Full name: $fullname | Shell: $shell_to_use | Groups: ${groups:-none}"
  useradd -m -s "$shell_to_use" -c "$fullname" $extra_groups "$username"

  # Generate a random password
  local pw
  pw="$(openssl rand -base64 12)"

  echo "$username:$pw" | chpasswd

  # Force password change at first login
  chage -d 0 "$username"

  # Output creds (you will store this securely)
  if [[ ! -f "$CREDS_FILE" ]]; then
    echo "username,password" > "$CREDS_FILE"
  fi
  echo "$username,$pw" >> "$CREDS_FILE"

  log "Created user: $username"
  return 0
}

main() {
  require_root

  if [[ ! -f "$CSV_FILE" ]]; then
    echo "CSV not found: $CSV_FILE"
    exit 1
  fi

  log "=== Run start: bulk create from $CSV_FILE ==="

  # Read CSV (skip header)
  tail -n +2 "$CSV_FILE" | while IFS=',' read -r username fullname groups shell; do
    # Trim spaces
    username="$(echo "${username:-}" | xargs || true)"
    fullname="$(echo "${fullname:-}" | xargs || true)"
    groups="$(echo "${groups:-}" | sed 's/ //g' || true)"
    shell="$(echo "${shell:-}" | xargs || true)"

    if [[ -z "$username" ]]; then
      log "Skipping empty line"
      continue
    fi

    if ! valid_username "$username"; then
      log "Invalid username '$username' (must be [a-z_][a-z0-9._-]*) – skipping"
      continue
    fi

    create_user "$username" "$fullname" "$groups" "$shell" || true
  done

  log "=== Run complete. Credentials file: $CREDS_FILE ==="
  # Secure creds file
  chmod 600 "$CREDS_FILE" 2>/dev/null || true
}

main "$@"
