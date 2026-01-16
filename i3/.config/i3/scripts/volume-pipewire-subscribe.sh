#!/bin/bash
# Background daemon that sends signal to i3blocks when audio changes
# Run this once at i3 startup

# Prevent multiple instances
exec 200>/tmp/volume-pipewire-subscribe.lock
flock -n 200 || exit 0

exec pactl subscribe 2>/dev/null | while read -r line; do
    if [[ "$line" == *"change"* ]]; then
        pkill -RTMIN+10 i3blocks
    fi
done
