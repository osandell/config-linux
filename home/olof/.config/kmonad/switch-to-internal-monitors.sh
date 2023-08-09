#!/usr/bin/env bash

bluetoothctl scan off >/dev/null 2>&1 &

hyprctl keyword monitor eDP-1,3072x1920@60,0x0,1.8

hyprctl dispatch movewindowpixel exact 0 0,'^kitty$'
hyprctl dispatch resizewindowpixel exact 650 1066,'^kitty$'
hyprctl dispatch movewindowpixel exact 655 0,'^GitKraken$'
hyprctl dispatch resizewindowpixel exact 1050 1066,'^GitKraken$'
hyprctl dispatch resizewindowpixel exact 1705 1066,'^google-chrome$'
hyprctl dispatch movewindowpixel exact 0 0,'^google-chrome$'
hyprctl dispatch movewindowpixel exact 0 0,'^(.*code-url-handler.*)$'
hyprctl dispatch resizewindowpixel exact 1705 1066,'^(.*code-url-handler.*)$'

# Capture the output of the command into a variable
output=$(hyprctl clients)

# Using a while loop to process the data line-by-line
echo "$output" | while read -r line; do
  # If the line contains "class: firefox", flag it
  if echo "$line" | grep -q "class: firefox"; then
    is_firefox=true
  fi

  # If we're processing a Firefox entry and we encounter the PID line
  if [ "$is_firefox" = true ] && echo "$line" | grep -q "pid: "; then
    pid=$(echo "$line" | awk '{print $2}')                        # extract the PID
    hyprctl dispatch resizewindowpixel exact 1705 1066,"pid:$pid" # execute the command with the PID
    hyprctl dispatch movewindowpixel exact 0 0,"pid:$pid"
    is_firefox=false # reset the flag for the next entry
  fi
done

killall kmonad

script_dir=$(dirname "$0")

config_file=~/.config/kmonad/defcfg.part

output=$(timeout 0.5 evtest 2>&1)
keyboard_line=$(echo "$output" | grep "Olof – Magic Keyboard")
event_id=$(echo "$keyboard_line" | awk -F ':' '{print $1}')

echo "$event_id" >"${script_dir}/bt-keyboard-id.txt"

# Activate internal keyboard
sed -i -e '\|;; internal|s|^.*$|input (device-file "/dev/input/by-id/usb-Apple_Inc._Apple_Internal_Keyboard___Trackpad_FM710660210HYYKCP+RVZ-if01-event-kbd") ;; internal|' -e '\|;; external|s|^.*$|;; external|' $config_file

cat "${script_dir}/defcfg.part" "${script_dir}/system-specific.part" "${script_dir}/shared.part" >"${script_dir}/kmonad.kbd"

/home/olof/.local/bin/kmonad "${script_dir}/kmonad.kbd" &
