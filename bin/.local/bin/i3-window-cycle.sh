#!/bin/bash
# Cycle through windows in the current group
# Usage: i3-window-cycle.sh next|prev

STATE_FILE="/tmp/i3-window-group"
IDX_FILE="/tmp/i3-window-group-idx"

[ ! -f "$STATE_FILE" ] && exit 0

read -ra ids < "$STATE_FILE"
total=${#ids[@]}
[ "$total" -le 1 ] && exit 0

current=$(cat "$IDX_FILE" 2>/dev/null || echo 0)

case "$1" in
    next) current=$(( (current + 1) % total )) ;;
    prev) current=$(( (current - 1 + total) % total )) ;;
esac

echo "$current" > "$IDX_FILE"
i3-msg "[con_id=${ids[$current]}] focus" > /dev/null
