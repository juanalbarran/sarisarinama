  # Pairs, connects, disconnects or forgets one Bluetooth device.
  #
  #   sarisarinama-bluetooth-device pair|connect|disconnect|forget <address>
  #
  # Ported from omarchy's omarchy-bluetooth-device. Through bluetoothctl and
  # not BlueZ's D-Bus calls from the shell: bluetoothctl registers an agent of
  # its own, which BlueZ needs to pair, and the shell has none. A paired
  # device is trusted, so it may connect back by itself later. Exits non-zero
  # when the device did not end up as asked, so the panel can say so.
  # bluetoothctl comes from PATH, so it matches the system's BlueZ.

  usage() {
      echo "usage: sarisarinama-bluetooth-device pair|connect|disconnect|forget <address>" >&2
      exit 2
  }

  action=${1:-}
  address=${2:-}

  case "$action" in
      pair | connect | disconnect | forget) ;;
      *) usage ;;
  esac
  [[ $address =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]] || usage

  info() {
      timeout 3s bluetoothctl info "$address" 2>/dev/null
  }

  is() {
      [[ $(info) == *"$1: yes"* ]]
  }

  # Turning on goes through the power script: bluetoothctl alone cannot while
  # the rfkill block is set.
  power_on() {
      [[ $(timeout 2s bluetoothctl show 2>/dev/null) == *"Powered: yes"* ]] && return 0
      sarisarinama-bluetooth-power on || true
  }

  case "$action" in
      pair)
          power_on
          timeout 20s bluetoothctl pair "$address" >/dev/null 2>&1 || true
          is Paired || exit 1
          timeout 5s bluetoothctl trust "$address" >/dev/null 2>&1 || true
          timeout 20s bluetoothctl connect "$address" >/dev/null 2>&1 || true
          is Connected
          ;;
      connect)
          power_on
          timeout 5s bluetoothctl trust "$address" >/dev/null 2>&1 || true
          timeout 20s bluetoothctl connect "$address" >/dev/null 2>&1 || true
          is Connected
          ;;
      disconnect)
          timeout 10s bluetoothctl disconnect "$address" >/dev/null 2>&1 || true
          ! is Connected
          ;;
      forget)
          timeout 10s bluetoothctl disconnect "$address" >/dev/null 2>&1 || true
          timeout 10s bluetoothctl remove "$address" >/dev/null 2>&1 || true
          ! is Paired
          ;;
  esac
