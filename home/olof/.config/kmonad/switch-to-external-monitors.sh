#!/usr/bin/env bash

# Check if external monitor is connected
is_external_monitor_connected=$(hyprctl monitors | grep -q 'S2721QS 8YTLM43' && echo "true" || echo "false")
if [[ $is_external_monitor_connected == "true" ]]; then

  killall bluetoothctl
  bluetoothctl scan on >/dev/null 2>&1 &

  # Get monitor IDs
  left_monitor_id=$(hyprctl monitors | awk '/S2721QS 8YTLM43/' | awk -F'[()]' '{print $2}')
  right_monitor_id=$(hyprctl monitors | awk '/S2721QS 8BJB513/' | awk -F'[()]' '{print $2}')

  # Set up monitors

  echo "left_monitor_id: $left_monitor_id"
  echo "right_monitor_id: $right_monitor_id"

  sleep 3
  # hyprctl keyword monitor eDP-1,3072x1920@60,0x0,1.8
  # hyprctl keyword monitor $left_monitor_id,disable
  sleep 3
  hyprctl keyword monitor $left_monitor_id,3840x2160@60,1706x0,1.8
  sleep 3
  hyprctl keyword monitor $right_monitor_id,3839x2160@60,3840x0,1.8,transform,3
  # hyprctl keyword monitor $right_monitor_id,disable
  # sleep 3
  # hyprctl keyword monitor $left_monitor_id,preferred,auto,1.8
  # sleep 3
  # hyprctl keyword monitor $right_monitor_id,preferred,auto,1.8,transform,3

  hyprctl keyword monitor eDP-1,disable

  # Array of workspace numbers
  left_monitor_workspaces=(1 2 4 5 6 7 8 9 0)

  # Move workspaces to according monitor
  for workspace in ${left_monitor_workspaces[@]}; do
    hyprctl dispatch moveworkspacetomonitor "$workspace $left_monitor_id"
  done

  hyprctl dispatch moveworkspacetomonitor "3 $right_monitor_id" # 'dev' workspace

  hyprctl dispatch movewindowpixel exact 1766 40,'^kitty$'
  hyprctl dispatch resizewindowpixel exact 800 1120,'^kitty$'
  hyprctl dispatch movewindowpixel exact 2586 40,'^GitKraken$'
  hyprctl dispatch resizewindowpixel exact 1200 1120,'^GitKraken'

  hyprctl dispatch movewindowpixel exact 1766 40,'^(.*code-url-handler.*)$'
  hyprctl dispatch resizewindowpixel exact 2010 1120,'^(.*code-url-handler.*)$'

  hyprctl dispatch movewindowpixel exact 1766 40,'^(.*slack.*)$'
  hyprctl dispatch resizewindowpixel exact 2010 1120,'^(.*slack.*)$'

  hyprctl dispatch movewindowpixel exact 3839 200,'^google-chrome$'
  hyprctl dispatch resizewindowpixel exact 1200 1600,'^google-chrome'

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
      pid=$(echo "$line" | awk '{print $2}')
      hyprctl dispatch movewindowpixel exact 1766 40,"pid:$pid"
      hyprctl dispatch resizewindowpixel exact 2010 1120,"pid:$pid"
      is_firefox=false # reset the flag for the next entry
    fi
  done

  # sleep 3
  # hyprctl keyword monitor eDP-1,disable

  killall kmonad

  script_dir=$(dirname "$0")

  config_file=~/.config/kmonad/defcfg.part

  output=$(timeout 0.5 evtest 2>&1)
  keyboard_line=$(echo "$output" | grep "Olof – Magic Keyboard")
  event_id=$(echo "$keyboard_line" | awk -F ':' '{print $1}')

  echo "$event_id" >"${script_dir}/bt-keyboard-id.txt"

  # Check if the external keyboard is connected
  if ls $event_id >/dev/null 2>&1; then
    echo "is conn ($event_id)"

    # Activate external keyboard
    sed -i -e '\|;; external|s|^.*$|input (device-file "'"$event_id"'") ;; external|' -e '\|;; internal|s|^.*$|;; internal|' $config_file
  fi

  cat "${script_dir}/defcfg.part" "${script_dir}/system-specific.part" "${script_dir}/shared.part" >"${script_dir}/kmonad.kbd"

  /home/olof/.local/bin/kmonad "${script_dir}/kmonad.kbd" &

  killall hyprpaper
  sleep 1
  hyprpaper >/dev/null 2>&1 &
fi
