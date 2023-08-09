#!/usr/bin/env bash

# Get ID of left monitor
monitor_id=$(hyprctl monitors | awk '/S2721QS 8YTLM43/' | awk -F'[()]' '{print $2}')

# Array of workspace numbers
workspaces=(1 2 4 5 6 7 8 9 0)

# Move each workspace to the monitor
for workspace in ${workspaces[@]}; do
  hyprctl dispatch moveworkspacetomonitor "$workspace $monitor_id"
done

# Get ID of right monitor
monitor_id=$(hyprctl monitors | awk '/S2721QS 8BJB513/' | awk -F'[()]' '{print $2}')

# Move 'Dev' browser to right monitor
hyprctl dispatch moveworkspacetomonitor "3 $monitor_id"

hyprctl keyword monitor eDP-1,disable
hyprctl keyword monitor eDP-2,disable
hyprctl keyword monitor DP-8,disable
hyprctl keyword monitor DP-8,preferred,auto,1.8,transform,3
