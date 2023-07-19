if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
  # Start SSH agent
  if ! pgrep -q -u "$USER" ssh-agent; then
    ssh-agent -s | head -2 >"${HOME}/.ssh/agent-info-${HOST}"
  fi

  if [[ -e "${HOME}/.ssh/agent-info-${HOST}" ]]; then
    source "${HOME}/.ssh/agent-info-${HOST}"
  fi

  # Add SSH keys
  if [[ -n "$SSH_AGENT_PID" ]]; then
    ssh-add ~/.ssh/github-osandell
  fi

  sudo /usr/bin/modprobe -r apple_touchbar
  systemctl start bluetooth.service
  systemctl start iwd.service

  # The order that the system discovers the iGPU and dGPU vary from boot to boot so we
  # can't hardcode that. Instad we here find out the id of the AMD dGPU.
  monitor=$(echo /sys/class/drm/$(basename $(readlink /dev/dri/by-path/pci-0000:03:00.0-card))-eDP-? | cut -d - -f2-)

  # Replace the monitor value in the Hyperland configuration file. The reason
  # for doing this is to prevent all sorts of bugs where Hyperland would think
  # that we have 2 moitors connected even when only internal MacBook display is used.
  sed -i "s/monitor=eDP-[1-2],disable/monitor=$monitor,disable/" ~/.config/hypr/disable-dgpu.conf

  Hyprland
fi
