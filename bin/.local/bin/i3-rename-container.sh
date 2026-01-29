#!/bin/bash
# Capture focused container ID before zenity steals focus
CON_ID=$(i3-msg -t get_tree | jq -r '.. | objects | select(.focused==true) | .id')

NEW=$(zenity --text="Enter container name:" --entry --title="Rename container")
if [ -n "$NEW" ]; then
    i3-msg "[con_id=\"$CON_ID\"] title_format \"$NEW\""
fi
