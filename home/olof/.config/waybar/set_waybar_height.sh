#!/bin/bash

# Fetch current WAYBAR_HEIGHT from the Waybar config file
WAYBAR_HEIGHT=$(parse_jsonc ~/.config/waybar/config.jsonc height)

# WORKSPACE_HEIGHT is the screen area apart from waybar
WORKSPACE_HEIGHT=$((1066-WAYBAR_HEIGHT))

# Update the WAYBAR_HEIGHT and WORKSPACE_HEIGHT in the Hypr config file
sed -i "s/\(WAYBAR_HEIGHT=\)[0-9]*/\1$WAYBAR_HEIGHT/" ~/.config/hypr/hyprland.conf
sed -i "s/\(WORKSPACE_HEIGHT=\)[0-9]*/\1$WORKSPACE_HEIGHT/" ~/.config/hypr/hyprland.conf
