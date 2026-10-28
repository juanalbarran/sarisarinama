# modules/ui/theme/presets/rose-pine.nix
# Not an omarchy theme: rose-pine/neovim's main variant (#55), each key
# the palette name omarchy gives it in Dawn: base, overlay, highlight_med
# and highlight_high, text, muted and subtle, and the hues as the plugin's
# terminal colours have them (pine green, rose cyan). dark_background is
# _nc, the plugin's unfocused-window base; darker_background and brown are
# left to the cascade. Orange is love and gold half and half, as omarchy's
# Dawn orange is.
{
  flake.modules.homeManager.sarisarinama = {
    programs.sarisarinama.theme.palettes.rose-pine = {
      mode = "dark";

      accent = "#9ccfd8";
      selection = "#403d52";
      muted = "#524f67";

      background = "#191724";
      dark_background = "#16141f";
      lighter_background = "#26233a";

      foreground = "#e0def4";
      dark_foreground = "#6e6a86";
      light_foreground = "#908caa";
      bright_foreground = "#e0def4";

      red = "#eb6f92";
      yellow = "#f6c177";
      orange = "#f09884";
      green = "#31748f";
      cyan = "#ebbcba";
      blue = "#9ccfd8";
      magenta = "#c4a7e7";

      bright_red = "#eb6f92";
      bright_yellow = "#f6c177";
      bright_green = "#31748f";
      bright_cyan = "#ebbcba";
      bright_blue = "#9ccfd8";
      bright_magenta = "#c4a7e7";
    };
  };
}
