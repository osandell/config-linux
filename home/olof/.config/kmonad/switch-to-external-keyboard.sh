#!/usr/bin/env bash

# Define the configuration file path
config_file=~/.config/kmonad/defcfg.part

# Define the event id file path
event_id_file=$(dirname "$0")/bt-keyboard-id.txt

# Read the event id from the file
event_id=$(cat "$event_id_file")

# Check if the BT keyboard is connected
if ls $event_id >/dev/null 2>&1; then
    # If the device exists, check if the line is commented in the file
    if grep -q ";; input (device-file \"$event_id\")" $config_file; then
        # If so we activate BT keyboard by uncommenting both lines then comment internal kb line
        sed -i -e "s|;; input (device-file \"$event_id\")|input (device-file \"$event_id\")|" -e 's/input (device-file "\/dev\/input\/by-id\/usb-Apple_Inc._Apple_Internal_Keyboard___Trackpad_FM710660210HYYKCP+RVZ-if01-event-kbd")/;; &/' $config_file
        
        # Also move workspaces to external monitors
        ~/.config/kmonad/swap-monitors.sh
    else
        # If not it means that the BT keyboard is active so we swap to internal
        sed -i -e "s|input (device-file \"$event_id\")|;; input (device-file \"$event_id\")|" -e 's/;; input (device-file "\/dev\/input\/by-id\/usb-Apple_Inc._Apple_Internal_Keyboard___Trackpad_FM710660210HYYKCP+RVZ-if01-event-kbd")/input (device-file "\/dev\/input\/by-id\/usb-Apple_Inc._Apple_Internal_Keyboard___Trackpad_FM710660210HYYKCP+RVZ-if01-event-kbd")/' $config_file
    fi
else
    # If BT keyboard is disconnected we make sure to activate internal
    sed -i -e "s|;; input (device-file \"$event_id\")|input (device-file \"$event_id\")|" -e 's/input (device-file "\/dev\/input\/by-id\/usb-Apple_Inc._Apple_Internal_Keyboard___Trackpad_FM710660210HYYKCP+RVZ-if01-event-kbd")/;; &/' $config_file
fi
