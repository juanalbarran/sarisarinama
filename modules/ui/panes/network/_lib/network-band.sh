# modules/ui/panes/network/_lib/network-band.sh
  # The Wi-Fi band of the connected network, for the panel's band row.
  #
  #   sarisarinama-network-band              prints band, available, selected
  #   sarisarinama-network-band auto|2.4|5|6 pins the band on the network's
  #                                          saved profile and reconnects
  #
  # Ported from omarchy's omarchy-network-band, with nmcli alone. A band the
  # network does not answer on is never offered nor accepted, and a pin that
  # cannot connect is undone, so the machine is not left offline. nmcli is the
  # system's, from PATH, so it always matches the NetworkManager running.

  # Every read goes through here: LC_ALL=C because nmcli translates words such
  # as "connected"; -e no because -g would otherwise escape ':' in an SSID.
  nm_get() {
      LC_ALL=C nmcli -e no -g "$@" 2>/dev/null
  }

  # "5180 MHz" -> 5. The same boundaries as omarchy's.
  band_for_freq() {
      local mhz=${1%%[!0-9]*}
      [ -n "$mhz" ] || return 1
      if ((mhz >= 2400 && mhz < 2500)); then
          echo 2.4
      elif ((mhz >= 4900 && mhz < 5925)); then
          echo 5
      elif ((mhz >= 5925 && mhz < 7125)); then
          echo 6
      else
          return 1
      fi
  }

  # NetworkManager's names for a band; 6GHz needs NetworkManager 1.44 or later.
  nm_band_for() {
      case "$1" in
      2.4) echo bg ;;
      5) echo a ;;
      6) echo 6GHz ;;
      *) return 1 ;;
      esac
  }

  band_from_nm() {
      case "$1" in
      bg) echo 2.4 ;;
      a) echo 5 ;;
      6GHz) echo 6 ;;
      *) echo auto ;;
      esac
  }

  # The connected Wi-Fi device, or nothing.
  wifi_device() {
      local dev type state
      while IFS=: read -r dev type state; do
          if [ "$type" = wifi ] && [ "$state" = connected ]; then
              printf '%s' "$dev"
              return 0
          fi
      done < <(nm_get DEVICE,TYPE,STATE device status)
  }

  # Sets $ssid and $band from the access point in use. SSID is asked for last,
  # so `read` hands it over whole even when it contains ':'.
  read_link() {
      local inuse freq name
      ssid=""
      band=""
      while IFS=: read -r inuse freq name; do
          if [ "$inuse" = "*" ]; then
              ssid="$name"
              band=$(band_for_freq "$freq" || true)
              return 0
          fi
      done < <(nm_get IN-USE,FREQ,SSID device wifi list ifname "$1" --rescan no)
  }

  # Every band the SSID answers on, low to high, always including the one in
  # use: a weak radio can be missed by a scan, but not the band we are on.
  # --rescan no reads NetworkManager's cache, which the panel's scanner keeps
  # warm, so a status never waits for a scan.
  available_bands() {
      local inuse freq name
      {
          if [ -n "$band" ]; then echo "$band"; fi
          while IFS=: read -r inuse freq name; do
              if [ "$name" = "$ssid" ]; then
                  band_for_freq "$freq" || true
              fi
          done < <(nm_get IN-USE,FREQ,SSID device wifi list ifname "$device" --rescan no)
      } | sort -u -g | tr '\n' ' ' | sed 's/ $//'
  }

  device=$(wifi_device)

  if [ $# -eq 0 ]; then
      [ -n "$device" ] || exit 0
      read_link "$device"
      [ -n "$ssid" ] || exit 0
      uuid=$(nm_get GENERAL.CON-UUID device show "$device")
      printf 'band\t%s\n' "$band"
      printf 'available\t%s\n' "$(available_bands)"
      printf 'selected\t%s\n' "$(band_from_nm "$(nm_get 802-11-wireless.band connection show uuid "$uuid")")"
      exit 0
  fi

  target="$1"
  case "$target" in
  auto | 2.4 | 5 | 6) ;;
  *)
      echo "Usage: sarisarinama-network-band [auto|2.4|5|6]" >&2
      exit 2
      ;;
  esac

  if [ -z "$device" ]; then
      echo "No Wi-Fi connection" >&2
      exit 1
  fi
  uuid=$(nm_get GENERAL.CON-UUID device show "$device")

  if [ "$target" = auto ]; then
      desired=""
  else
      read_link "$device"
      if [[ " $(available_bands) " != *" $target "* ]]; then
          echo "This network does not answer on ${target} GHz" >&2
          exit 1
      fi
      desired=$(nm_band_for "$target")
  fi

  previous=$(nm_get 802-11-wireless.band connection show uuid "$uuid")
  [ "$previous" != "$desired" ] || exit 0

  nmcli connection modify uuid "$uuid" 802-11-wireless.band "$desired" >/dev/null
  # A band takes effect only on reconnecting. If the radio cannot come back on
  # the new band, the old setting is put back and the network reconnected.
  if ! nmcli -w 30 connection up uuid "$uuid" >/dev/null 2>&1; then
      nmcli connection modify uuid "$uuid" 802-11-wireless.band "$previous" >/dev/null
      nmcli -w 30 connection up uuid "$uuid" >/dev/null 2>&1 || true
      echo "Could not connect on ${target} GHz; the previous band is back" >&2
      exit 1
  fi
