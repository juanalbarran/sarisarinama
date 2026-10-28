# modules/ui/theme/presets/gruvbox-light.nix
# Not an omarchy theme: omarchy's gruvbox mirrored onto the light side
# (#51). gruvbox's light0..light4 and dark3 where omarchy has dark0..dark4
# and light3, light0_soft and light1 for the two darker backgrounds, and
# gruvbox-material's light `material` foreground for the text and the
# hues. `brown` is left to the cascade, orange 50% into black, as
# omarchy's dark one is.
{
  flake.modules.homeManager.sarisarinama = {
    programs.sarisarinama.theme.palettes.gruvbox-light = {
      mode = "light";

      accent = "#45707a";
      selection = "#d5c4a1";
      muted = "#bdae93";

      background = "#fbf1c7";
      dark_background = "#f2e5bc";
      darker_background = "#ebdbb2";
      lighter_background = "#ebdbb2";

      foreground = "#654735";
      dark_foreground = "#a89984";
      light_foreground = "#665c54";
      bright_foreground = "#654735";

      red = "#c14a4a";
      yellow = "#b47109";
      orange = "#c35e0a";
      green = "#6c782e";
      cyan = "#4c7a5d";
      blue = "#45707a";
      magenta = "#945e80";

      bright_red = "#c14a4a";
      bright_yellow = "#b47109";
      bright_green = "#6c782e";
      bright_cyan = "#4c7a5d";
      bright_blue = "#45707a";
      bright_magenta = "#945e80";
    };
  };
}
