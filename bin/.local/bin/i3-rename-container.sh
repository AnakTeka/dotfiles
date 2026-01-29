#!/bin/bash
NEW=$(zenity --text="Enter container name:" --entry --title="Rename container")
if [ -n "$NEW" ]; then
    i3-msg "title_format \"$NEW\""
fi
