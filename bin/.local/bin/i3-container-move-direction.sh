#!/usr/bin/env bash
# Move container to the output in the specified direction (left/right).
# If no output exists in that direction, wrap around to the other side.

direction=${1:-right}   # "left" or "right"

# Get active outputs sorted by x position (left to right)
mapfile -t outputs < <(
    i3-msg -t get_outputs | jq -r '
        [.[] | select(.active)] | sort_by(.rect.x) | .[].name
    '
)

# Get current output
current=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused).output')

(( ${#outputs[@]} == 0 )) && exit 1
(( ${#outputs[@]} == 1 )) && exit 0  # only one output, nothing to do

# Find current index
current_idx=-1
for i in "${!outputs[@]}"; do
    [[ ${outputs[$i]} == "$current" ]] && current_idx=$i && break
done

[[ $current_idx -lt 0 ]] && exit 1

# Determine target based on direction
if [[ $direction == "right" ]]; then
    # Try to go right, wrap to leftmost if at the end
    target_idx=$(( (current_idx + 1) % ${#outputs[@]} ))
else
    # Try to go left, wrap to rightmost if at the start
    target_idx=$(( (current_idx - 1 + ${#outputs[@]}) % ${#outputs[@]} ))
fi

target=${outputs[$target_idx]}

# Move container to target output
i3-msg "move container to output $target; focus output $target" >/dev/null
