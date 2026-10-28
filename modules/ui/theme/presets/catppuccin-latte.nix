# modules/ui/theme/presets/catppuccin-latte.nix
# omarchy themes/catppuccin-latte/colors.toml, with Catppuccin Latte's own
# colours wherever omarchy strays from the palette (#48): Base #eff1f5 for
# the background (#42 had white's #ffffff), Peach for orange, Mantle and
# Crust for the dark backgrounds. Catppuccin has no brown; Rosewater, its
# closest hue, stands in.
{
  flake.modules.homeManager.sarisarinama = {
    programs.sarisarinama.theme.palettes.catppuccin-latte = {
      mode = "light";

      accent = "#1e66f5";
      selection = "#ccd0da";
      muted = "#acb0be";

      background = "#eff1f5";
      dark_background = "#e6e9ef";
      darker_background = "#dce0e8";
      lighter_background = "#dce0e8";

      foreground = "#4c4f69";
      dark_foreground = "#9ca0b0";
      light_foreground = "#5c5f77";
      bright_foreground = "#4c4f69";

      red = "#d20f39";
      yellow = "#df8e1d";
      orange = "#fe640b";
      green = "#40a02b";
      cyan = "#179299";
      blue = "#1e66f5";
      magenta = "#ea76cb";
      brown = "#dc8a78";

      bright_red = "#d20f39";
      bright_yellow = "#df8e1d";
      bright_green = "#40a02b";
      bright_cyan = "#179299";
      bright_blue = "#1e66f5";
      bright_magenta = "#ea76cb";
    };
  };
}
