  # Turns Bluetooth on or off, remembered across reboots.
  #
  #   sarisarinama-bluetooth-power on|off|is-on
  #
  # Ported from omarchy's omarchy-bluetooth-power. BlueZ never saves an
  # adapter's Powered, so turning it off through BlueZ lasts until the next
  # boot. The rfkill soft block does last: systemd-rfkill saves it and puts it
  # back early in the next boot. So the block is the state and BlueZ follows
  # it; turning on also has to lift the block, as BlueZ refuses to power an
  # adapter up while one is set. rfkill and bluetoothctl come from PATH, so
  # they match the system's BlueZ.

  # Seconds to wait for the adapter to report itself powered.
  wait_seconds=${SARISARINAMA_BLUETOOTH_POWER_WAIT:-2}

  controllers() {
      timeout 2s bluetoothctl list 2>/dev/null | awk '{print $2}'
  }

  # Any controller counts: the block takes every radio at once.
  powered() {
      local controller
      for controller in $(controllers); do
          [[ $(timeout 2s bluetoothctl show "$controller" 2>/dev/null) == *"Powered: yes"* ]] && return 0
      done
      return 1
  }

  # One deadline around the whole wait, not a count of probes: each probe can
  # sit on its own timeout when D-Bus is stuck.
  wait_powered() {
      local deadline=$((SECONDS + wait_seconds))
      while :; do
          powered && return 0
          ((SECONDS < deadline)) || return 1
          sleep 0.2
      done
  }

  power_on() {
      rfkill unblock bluetooth
      # Usually enough: once the block is gone bluetoothd powers the adapter
      # up by itself. It will not for one powered down without a block.
      wait_powered && return 0
      timeout 5s bluetoothctl power on >/dev/null 2>&1 || true
      wait_powered && return 0
      echo "sarisarinama-bluetooth-power: the adapter did not come up" >&2
      return 1
  }

  case "${1:-}" in
      on)
          power_on
          ;;
      off)
          # The block alone drops the adapter to Powered: no, and it is the
          # half that survives a reboot.
          rfkill block bluetooth
          ;;
      is-on)
          powered
          ;;
      *)
          echo "usage: sarisarinama-bluetooth-power on|off|is-on" >&2
          exit 2
          ;;
  esac
