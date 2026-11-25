# modules/ui/theme/integrations/hyprland/_lib/theme-hyprland.sh
# sarisarinama-theme-hyprland [name]: the theme's hyprland.conf is copied to
# the file Hyprland's config sources, so the borders survive a reload and a
# restart, and sourced into the running Hyprland, which repaints at once. No
# name means the theme in use. Ported from omarchy's
# omarchy-theme-set-hyprland.

# install, not cp: the source is read-only in the Nix store.
install -Dm644 "$config/hyprland/$name.conf" "$state/hyprland.conf"

# Sourced, never `hyprctl reload`: a reload reruns the config's `exec` lines,
# which restart the shell. Without Hyprland's variable, as from Sway or a
# Home Manager switch, there is no Hyprland to tell; it reads the copy when
# it next starts or reloads. hyprctl from PATH: only the running Hyprland's
# own copy is sure to speak its protocol.
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  hyprctl keyword source "$state/hyprland.conf" >/dev/null
fi
