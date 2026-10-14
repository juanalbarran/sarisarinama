# modules/ui/theme/integrations/_lib/current-theme.sh
# Put by Nix at the top of every integration script: sets $config, $state
# and $name, the theme to apply. $1 names it; without it, the theme in use:
# current.json, else theme.json. A name with no rendered palette (a theme
# removed since) falls back to theme.json too.

config="${XDG_CONFIG_HOME:-$HOME/.config}/sarisarinama"
state="${XDG_STATE_HOME:-$HOME/.local/state}/sarisarinama"

name="${1:-}"
if [ -z "$name" ]; then
  name=$(jq -r '.default // empty' "$config/current.json" 2>/dev/null || true)
fi
if [ -z "$name" ] || [ ! -e "$config/themes/$name.json" ]; then
  name=$(jq -r '.default' "$config/theme.json")
fi
