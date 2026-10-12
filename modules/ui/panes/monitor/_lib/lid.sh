# modules/ui/panes/monitor/_lib/lid.sh
# sarisarinama-lid closed|open: puts the laptop panel in the state the lid
# asks for. Closed with an external output active turns the panel off;
# anything else turns it on, so the last screen is never switched off.
# The compositor's lid bind passes the state: /proc/acpi/button/lid can lie.
#
# swaymsg and hyprctl come from PATH: only the running compositor's own
# copy speaks its socket's protocol.

state="${1:-}"
case "$state" in
closed | open) ;;
*)
  echo "usage: sarisarinama-lid closed|open" >&2
  exit 2
  ;;
esac

# The same test omarchy uses: the built-in panel is eDP, LVDS or DSI.
internal_re='^(eDP|LVDS|DSI)-'

# Hyprland exports this into every client it launches; Sway does not.
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  outputs=$(hyprctl monitors all -j | jq -c '[.[] | {name, active: (.disabled != true)}]')
else
  outputs=$(swaymsg -t get_outputs -r | jq -c '[.[] | {name, active}]')
fi

internal=$(jq -r --arg re "$internal_re" \
  '[.[] | select(.name | test($re))][0].name // ""' <<<"$outputs")
[ -n "$internal" ] || exit 0

active=$(jq -r --arg name "$internal" \
  '.[] | select(.name == $name) | .active' <<<"$outputs")
externals=$(jq -r --arg re "$internal_re" \
  '[.[] | select((.name | test($re) | not) and .active)] | length' <<<"$outputs")

if [ "$state" = closed ] && [ "$externals" -gt 0 ]; then
  want=false
else
  want=true
fi

# Already right: do nothing, so a config reload does not re-light the panel.
[ "$active" = "$want" ] && exit 0

if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  if [ "$want" = true ]; then
    hyprctl keyword monitor "$internal,preferred,auto,auto" >/dev/null
  else
    hyprctl keyword monitor "$internal,disable" >/dev/null
  fi
else
  if [ "$want" = true ]; then
    swaymsg output "$internal" enable >/dev/null
  else
    swaymsg output "$internal" disable >/dev/null
  fi
fi
