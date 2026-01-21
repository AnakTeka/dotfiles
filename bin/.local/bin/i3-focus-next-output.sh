#!/usr/bin/env bash
# Cycle keyboard / mouse focus to the next (or previous) active output (Monitors)

direction=${1:-next}    # "next" (default) or "prev"

# 1. list of active outputs
mapfile -t outputs < <(
    i3-msg -t get_outputs | jq -r '.[] | select(.active) | .name'
)

# 2. name of the output that contains the *focused* workspace
current=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused).output')

# Safety net
(( ${#outputs[@]} == 0 )) && exit 1           # no outputs at all → abort

# 3. determine the neighbour we want to focus
for i in "${!outputs[@]}"; do
    [[ ${outputs[$i]} == "$current" ]] || continue

    if [[ $direction == next ]]; then
        target=${outputs[$(( (i + 1) % ${#outputs[@]} ))]}
    else
        target=${outputs[$(( (i - 1 + ${#outputs[@]}) % ${#outputs[@]} ))]}
    fi
    break
done

# Fallback: could not find current → pick first active output
target=${target:-${outputs[0]}}

# 4. hand it over to i3
i3-msg "focus output $target" >/dev/null
