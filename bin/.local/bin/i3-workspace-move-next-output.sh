#!/usr/bin/env bash
# Move current workspace to next / previous output
# and move the mouse pointer to the centre of that output.

direction=${1:-next}        # default = next; "prev" = previous

# -------------  list of active outputs ---------------------------------
mapfile -t outputs < <(
    i3-msg -t get_outputs | jq -r '.[] | select(.active) | .name'
)

# -------------  currently focused output (via workspace API) -----------
current=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused).output')

(( ${#outputs[@]} == 0 )) && exit 1      # nothing to do

# -------------  pick neighbour -----------------------------------------
for i in "${!outputs[@]}"; do
    [[ ${outputs[$i]} == "$current" ]] || continue

    if [[ $direction == next ]]; then
        target=${outputs[$(( (i + 1) % ${#outputs[@]} ))]}
    else
        target=${outputs[$(( (i - 1 + ${#outputs[@]}) % ${#outputs[@]} ))]}
    fi
    break
done
target=${target:-${outputs[0]}}          # fall-back

# -------------  move workspace and focus new output --------------------
i3-msg "move workspace to output $target" >/dev/null


# -------------  warp the cursor ----------------------------------------
if command -v xdotool >/dev/null; then
    read x y w h < <(
        i3-msg -t get_outputs |
        jq -r --arg t "$target" \
              '.[] | select(.name==$t) |
               "\(.rect.x) \(.rect.y) \(.rect.width) \(.rect.height)"'
    )
    # centre of the target output
    cx=$(( x + w / 2 ))
    cy=$(( y + h / 2 ))
    xdotool mousemove --sync "$cx" "$cy"
fi
