# modules/ui/theme/integrations/hyprland/_lib/hyprland-conf.nix
# A resolved palette as Hyprland's border colours, as omarchy's
# default/themed/hyprland.conf.tpl paints them: the focused window, and a
# focused group, in `accent`. The unfocused border is left to the config.
palette: let
  # Hyprland's rgb() takes the hex without its #.
  rgb = hex: "rgb(${builtins.substring 1 6 hex})";
in ''
  general {
    col.active_border = ${rgb palette.accent}
  }
  group {
    col.border_active = ${rgb palette.accent}
  }
''
