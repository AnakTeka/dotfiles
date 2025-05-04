#!/bin/bash

ldac=`pactl list | grep Active | grep a2dp`
card=`pactl list | grep "Name: bluez_card." | cut -d ' ' -f 2`


function switch_audio {
    if [ -n "$ldac" ]; then
        pactl set-card-profile $card off
        sleep 0.5
        pactl set-card-profile $card headset-head-unit-msbc
        echo " mSBC"
    else
        pactl set-card-profile $card off
        sleep 0.5
        pactl set-card-profile $card a2dp-sink
        # pactl set-card-profile $card a2dp-sink-sbc_xq
        echo " LDAC"
    fi

}
case "$BLOCK_BUTTON" in
    1) switch_audio ;;
esac

function print_current {
    if [ -n "$ldac" ]; then
        echo " LDAC"
    else
        echo " mSBC"
    fi
}
print_current
