#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="/opt/linux-admin-automation"
LOG_DIR="$PROJECT_ROOT/logs"
MON_LOG="$LOG_DIR/process_monitor.log"
mkdir -p "$LOG_DIR"

{
  echo "===== $(date '+%F %T') ====="
  echo "Uptime / load:"
  uptime || true
  echo

  echo "Memory summary:"
  free -h || true
  echo

  echo "Disk usage:"
  df -hT || true
  echo

  echo "Top 10 by CPU:"
  ps -eo pid,user,comm,%cpu,%mem --sort=-%cpu | head -n 11
  echo

  echo "Top 10 by MEM:"
  ps -eo pid,user,comm,%mem,%cpu --sort=-%mem | head -n 11
  echo
} >> "$MON_LOG" 2>&1
