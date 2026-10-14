# modules/ui/theme/integrations/palette/_lib/theme-palette.sh
# sarisarinama-theme-palette [name]: writes the theme's resolved palette,
# plus its name, to palette.json, the file other programs read and watch.
# Written beside it and renamed over it, so a reader never sees half a file.

mkdir -p "$state"
jq --arg name "$name" '. + {name: $name}' "$config/themes/$name.json" >"$state/palette.json.tmp"
mv "$state/palette.json.tmp" "$state/palette.json"
