# modules/ui/theme/presets/white.nix
# omarchy themes/white/colors.toml, verbatim. Black on white, 21:1, the
# light counterpart of vantablack. Upstream declares no `orange` and no
# `brown`; both are left to the cascade rather than invented here.
{
  flake.modules.homeManager.sarisarinama = {
    programs.sarisarinama.theme.palettes.white = {
      mode = "light";

      accent = "#6e6e6e";
      selection = "#c0c0c0";
      muted = "#808080";

      background = "#ffffff";
      dark_background = "#f5f5f5";
      darker_background = "#e8e8e8";
      lighter_background = "#c0c0c0";

      foreground = "#000000";
      dark_foreground = "#c0c0c0";
      light_foreground = "#000000";
      bright_foreground = "#000000";

      red = "#2a2a2a";
      yellow = "#4a4a4a";
      green = "#3a3a3a";
      cyan = "#3e3e3e";
      blue = "#1a1a1a";
      magenta = "#2e2e2e";

      bright_red = "#2a2a2a";
      bright_yellow = "#4a4a4a";
      bright_green = "#3a3a3a";
      bright_cyan = "#3e3e3e";
      bright_blue = "#1a1a1a";
      bright_magenta = "#2e2e2e";
    };
  };
}
