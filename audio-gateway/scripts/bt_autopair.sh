#!/usr/bin/env bash
set -euo pipefail
MAC="${BT_SPEAKER_MAC:-}"
if [ -z "$MAC" ]; then
  echo "[bt_autopair] No BT_SPEAKER_MAC provided; skipping."
  exit 0
fi

echo -e "power on\nagent on\ndefault-agent\ntrust $MAC\npair $MAC\nconnect $MAC\nquit\n" | bluetoothctl || true
SINK=$(pactl list short sinks | awk '{print $2}' | grep -i bluez | head -n1)
if [ -n "$SINK" ]; then
  pactl set-default-sink "$SINK" || true
  echo "[bt_autopair] Default sink set to $SINK"
else
  echo "[bt_autopair] No bluez sink found yet."
fi
