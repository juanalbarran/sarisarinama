# modules/ui/theme/integrations/hyprland/_lib/theme-hyprland.sh
# sarisarinama-theme-hyprland [name]: the theme's hyprland.conf is copied to
# the file Hyprland's config sources, so the borders survive a reload and a
# restart. No name means the theme in use. Ported from omarchy's
# omarchy-theme-set-hyprland.
#
# It never repaints the running Hyprland: `hyprctl reload` would rerun its
# `exec` lines, which restart the shell. The shell's own Hyprland backend
# sources the theme's file on `theme set` instead, then rereads the borders
# for the bar. See docs/themes.md.

# install, not cp: the source is read-only in the Nix store.
install -Dm644 "$config/hyprland/$name.conf" "$state/hyprland.conf"
