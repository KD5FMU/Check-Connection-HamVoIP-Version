#!/bin/sh
# Check/maintain links between MY_NODE and TARGET_NODES on HamVoIP (Arch-based)
# Skips reconnect if already linked. Add to cron for periodic checks.
# Freddie Mac (KD5FMU) — adapted for HamVoIP

# ========= USER SETTINGS =========
MY_NODE="123456"                   # <-- your node number
TARGET_NODES="1999 42518 58453"    # <-- space-separated targets
SLEEP_BETWEEN=1                    # seconds between attempts
# =================================

# Find asterisk
ASTERISK_BIN="$(command -v asterisk 2>/dev/null || true)"
[ -z "$ASTERISK_BIN" ] && [ -x /usr/sbin/asterisk ] && ASTERISK_BIN=/usr/sbin/asterisk
if [ ! -x "$ASTERISK_BIN" ]; then
  logger -t check_connection_hamvoip "ERROR: asterisk binary not found"
  echo "ERROR: asterisk binary not found" >&2
  exit 127
fi

asterisk_cli() { "$ASTERISK_BIN" -rnx "$1"; }

# Basic validation
case "$MY_NODE" in *[!0-9]*|"") logger -t check_connection_hamvoip "ERROR: MY_NODE must be numeric"; exit 2 ;; esac
[ -z "$TARGET_NODES" ] && { logger -t check_connection_hamvoip "ERROR: TARGET_NODES is empty"; exit 2; }

# Grab current link status ONCE to avoid racing output between loops
LINKS_RAW="$(asterisk_cli "rpt lstats $MY_NODE" 2>/dev/null)"

# Option: status-only mode
if [ "$1" = "--status" ]; then
  echo "=== rpt lstats $MY_NODE (raw) ==="
  echo "$LINKS_RAW"
  exit 0
fi

# Check helper (word boundaries so 1234 doesn't match 12345)
is_connected_to() {
  # returns 0 if TARGET appears in LINKS_RAW as a standalone node number
  # (^|[^0-9])<TARGET>([^0-9]|$)
  printf "%s" "$LINKS_RAW" | grep -Eq "(^|[^0-9])$1([^0-9]|$)"
}

connect_to() {
  asterisk_cli "rpt fun $MY_NODE *3$1"
}

RESULT=0
for TARGET in $TARGET_NODES; do
  case "$TARGET" in *[!0-9]*|"") logger -t check_connection_hamvoip "WARN: skipping non-numeric TARGET '$TARGET'"; RESULT=3; continue ;; esac

  if is_connected_to "$TARGET"; then
    logger -t check_connection_hamvoip "OK: $MY_NODE already linked to $TARGET (skipping)"
    echo "OK: $MY_NODE already linked to $TARGET (skipping)"
  else
    logger -t check_connection_hamvoip "INFO: $MY_NODE not linked to $TARGET; attempting connect"
    echo "Connecting $MY_NODE -> $TARGET ..."
    if connect_to "$TARGET"; then
      logger -t check_connection_hamvoip "INFO: issued DTMF *3$TARGET"
    else
      logger -t check_connection_hamvoip "ERROR: failed to issue DTMF *3$TARGET"
      RESULT=4
    fi
    [ "$SLEEP_BETWEEN" -gt 0 ] 2>/dev/null && sleep "$SLEEP_BETWEEN"
  fi
done

exit "$RESULT"
