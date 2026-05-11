#!/bin/bash

while true; do
    for sid in $(loginctl list-sessions --no-legend | awk '{print $1}'); do
        user=$(loginctl show-session "$sid" -p Name --value)
        type=$(loginctl show-session "$sid" -p Type --value)
        state=$(loginctl show-session "$sid" -p State --value)

        if [[ "$user" == "gdm" ]]; then
            continue
        fi

        if [[ "$state" == "active" ]] && ([[ "$type" == "wayland" ]] || [[ "$type" == "x11" ]]); then
            exit 0
        fi
    done

    sleep 1
done
