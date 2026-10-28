# modules/ui/theme/presets/everforest-light.nix
# Not an omarchy theme: omarchy's everforest mirrored onto everforest's own
# light, medium contrast (#54). Key for key the same names: bg0, bg1 and
# bg2 for the background, lighter background and selection, bg_dim and bg3
# for the two darker backgrounds, grey2 and fg, and the light hues. The
# light ramp is flatter than the dark, so where bg3 and bg4 would all but
# vanish, muted is bg5 and dark_foreground grey0, the nearest in contrast
# to their dark counterparts. `brown` is left to the cascade, orange 50%
# into black, as omarchy's dark one is.
{
  flake.modules.homeManager.sarisarinama = {
    programs.sarisarinama.theme.palettes.everforest-light = {
      mode = "light";

      accent = "#3a94c5";
      selection = "#efebd4";
      muted = "#bdc3af";

      background = "#fdf6e3";
      dark_background = "#efebd4";
      darker_background = "#e6e2cc";
      lighter_background = "#f4f0d9";

      foreground = "#5c6a72";
      dark_foreground = "#a6b0a0";
      light_foreground = "#829181";
      bright_foreground = "#5c6a72";

      red = "#f85552";
      yellow = "#dfa000";
      orange = "#f57d26";
      green = "#8da101";
      cyan = "#35a77c";
      blue = "#3a94c5";
      magenta = "#df69ba";

      bright_red = "#f85552";
      bright_yellow = "#dfa000";
      bright_green = "#8da101";
      bright_cyan = "#35a77c";
      bright_blue = "#3a94c5";
      bright_magenta = "#df69ba";
    };
  };
}
