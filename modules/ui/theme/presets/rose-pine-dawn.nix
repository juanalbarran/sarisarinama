# modules/ui/theme/presets/rose-pine-dawn.nix
# omarchy themes/rose-pine/colors.toml (Quattro), which is Rosé Pine Dawn
# (#55), with rose-pine/neovim's current text (#464261) and subtle
# (#797593) where omarchy has the older #575279 and #6e6a86. Its other
# keys are the plugin's own; the two darker backgrounds and orange (love
# and gold half and half) are omarchy's.
{
  flake.modules.homeManager.sarisarinama = {
    programs.sarisarinama.theme.palettes.rose-pine-dawn = {
      mode = "light";

      accent = "#56949f";
      selection = "#dfdad9";
      muted = "#cecacd";

      background = "#faf4ed";
      dark_background = "#ede7e1";
      darker_background = "#e1dbd5";
      lighter_background = "#f2e9e1";

      foreground = "#464261";
      dark_foreground = "#9893a5";
      light_foreground = "#797593";
      bright_foreground = "#464261";

      red = "#b4637a";
      yellow = "#ea9d34";
      orange = "#cf8057";
      green = "#286983";
      cyan = "#d7827e";
      blue = "#56949f";
      magenta = "#907aa9";
      brown = "#67402b";

      bright_red = "#b4637a";
      bright_yellow = "#ea9d34";
      bright_green = "#286983";
      bright_cyan = "#d7827e";
      bright_blue = "#56949f";
      bright_magenta = "#907aa9";
    };
  };
}
