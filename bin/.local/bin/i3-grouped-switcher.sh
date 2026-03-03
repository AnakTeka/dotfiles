#!/bin/bash
# Grouped window switcher for i3wm
# Groups windows with identical class+title, allows n/p cycling

STATE_FILE="/tmp/i3-window-group"
IDX_FILE="/tmp/i3-window-group-idx"

# Classes that group by class only (ignoring title)
GROUP_BY_CLASS=("Google-chrome" "Terminator")

# Title patterns that get grouped together (matched with jq test/regex)
# Windows matching these get their title replaced with the pattern label
GROUP_BY_TITLE=("Claude Code")

group_by_class_jq=$(printf '%s\n' "${GROUP_BY_CLASS[@]}" | jq -R . | jq -s .)
group_by_title_jq=$(printf '%s\n' "${GROUP_BY_TITLE[@]}" | jq -R . | jq -s .)

# Get all windows grouped accordingly
groups=$(i3-msg -t get_tree | jq -r --argjson gbc "$group_by_class_jq" --argjson gbt "$group_by_title_jq" '
  [
    recurse(.nodes[])
    | select(.type == "workspace" and .name != "__i3_scratch")
    | . as $ws
    | recurse(.nodes[], .floating_nodes[])
    | select(.window != null and .name != null)
    | {id, class: (.window_properties.class // "unknown"), title: .name, ws: $ws.name}
  ]
  | map(. + {
      title_match: (.title as $t | first($gbt[] | select(. as $pat | $t | test($pat))) // null),
    } | . + {
      group_key: (
        if .title_match then .class + "\u0001" + .title_match
        elif (.class | IN($gbc[])) then .class
        else .class + "\u0001" + .title end
      ),
      display_title: (.title_match // .title)
    })
  | group_by(.group_key)
  | sort_by(-length)
  | .[]
  | {
      count: length,
      class: .[0].class,
      title: .[0].display_title,
      has_title_match: (.[0].title_match != null),
      class_only: ((.[0].class | IN($gbc[])) and .[0].title_match == null),
      ids: ([.[].id | tostring] | join(" "))
    }
  | "\(.count)\t\(.ids)\t\(.class)\t\(.title)\t\(.class_only)"
')

[ -z "$groups" ] && exit 0

# Build rofi menu
mapfile -t lines <<< "$groups"
menu=""
for line in "${lines[@]}"; do
    IFS=$'\t' read -r count ids class title class_only <<< "$line"
    if [ "$count" -gt 1 ] && [ "$class_only" = "true" ]; then
        entry="[${count}] ${class}"
    elif [ "$count" -gt 1 ]; then
        entry="[${count}] ${class}: ${title}"
    else
        entry="${class}: ${title}"
    fi
    menu+="${menu:+$'\n'}${entry}"
done

# Show rofi, return selected index
idx=$(printf '%s' "$menu" | rofi -dmenu -i -p "switch" -format i)
[[ -z "$idx" || "$idx" == "-1" ]] && exit 0

# Get selected group data
IFS=$'\t' read -r count ids class title <<< "${lines[$idx]}"

# Save state and focus first window
echo "$ids" > "$STATE_FILE"
echo "0" > "$IDX_FILE"
i3-msg "[con_id=${ids%% *}] focus" > /dev/null

# Enter cycle mode if multiple windows in group
[ "$count" -gt 1 ] && i3-msg mode "window_cycle" > /dev/null
