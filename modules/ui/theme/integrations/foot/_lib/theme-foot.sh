# modules/ui/theme/integrations/foot/_lib/theme-foot.sh
# sarisarinama-theme-foot [name]: paints foot with a theme. The theme's
# foot.ini is copied to the file foot's config includes, for windows opened
# from now on; its colours go as OSC sequences to every foot already
# running, which repaints at once. No name means the theme in use:
# current.json, else theme.json. Ported from omarchy's
# omarchy-theme-set-foot.

config="${XDG_CONFIG_HOME:-$HOME/.config}/sarisarinama"
state="${XDG_STATE_HOME:-$HOME/.local/state}/sarisarinama"

name="${1:-}"
if [ -z "$name" ]; then
  name=$(jq -r '.default // empty' "$config/current.json" 2>/dev/null || true)
fi
# A name with no rendered file (a theme removed since) falls back too.
if [ -z "$name" ] || [ ! -e "$config/foot/$name.ini" ]; then
  name=$(jq -r '.default' "$config/theme.json")
fi
src="$config/foot/$name.ini"

# install, not cp: the source is read-only in the Nix store and cp keeps
# that mode, so the next switch could not overwrite the copy.
install -Dm644 "$src" "$state/foot.ini"

# The same colours as escape sequences: OSC 10/11 foreground and
# background, 12 the cursor, 17/19 the selection, 4;N palette entry N.
osc=""
while IFS='=' read -r key value; do
  case "$key" in
  foreground) code=10 ;;
  background) code=11 ;;
  selection-background) code=17 ;;
  selection-foreground) code=19 ;;
  # "cursor=<text> <cursor>": the cursor's own colour is the second.
  cursor)
    code=12
    value="${value#* }"
    ;;
  regular[0-7]) code="4;${key#regular}" ;;
  bright[0-7]) code="4;$((${key#bright} + 8))" ;;
  *) continue ;;
  esac
  osc+=$(printf '\033]%s;#%s\007' "$code" "$value")
done <"$src"

# Each foot's children share its terminal: writing there reaches foot
# itself, with or without tmux in between.
while read -r foot; do
  while read -r child; do
    tty=$(readlink "/proc/$child/fd/1" 2>/dev/null) || continue
    case "$tty" in
    /dev/pts/*) printf '%s' "$osc" >"$tty" 2>/dev/null || true ;;
    esac
  done < <(pgrep -P "$foot" || true)
done < <(pgrep -x foot || true)
