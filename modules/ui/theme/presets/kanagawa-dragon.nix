# modules/ui/theme/presets/kanagawa-dragon.nix
# Not an omarchy theme: omarchy ships only kanagawa (wave). Built from
# rebelot/kanagawa.nvim, mapping the dragon `term` table onto the same
# slots omarchy's kanagawa.toml takes from the wave one. Derived keys
# (dark_background, darker_background, brown) are left to the cascade.
{
  flake.modules.homeManager.sarisarinama = {
    programs.sarisarinama.theme.palettes.kanagawa-dragon = {
      mode = "dark";

      accent = "#c5c9c5"; # dragonWhite, as wave takes fujiWhite
      selection = "#393836"; # dragonBlack5
      muted = "#54546d"; # sumiInk6

      background = "#181616"; # dragonBlack3
      lighter_background = "#223249"; # waveBlue1

      foreground = "#c5c9c5"; # dragonWhite
      dark_foreground = "#737c73"; # dragonAsh, the dragon comment colour
      light_foreground = "#c8c093"; # oldWhite
      bright_foreground = "#c5c9c5"; # dragonWhite

      red = "#c4746e"; # dragonRed
      yellow = "#c4b28a"; # dragonYellow
      orange = "#b6927b"; # dragonOrange
      green = "#8a9a7b"; # dragonGreen2
      cyan = "#8ea4a2"; # dragonAqua
      blue = "#8ba4b0"; # dragonBlue2
      magenta = "#a292a3"; # dragonPink

      bright_red = "#e46876"; # waveRed
      bright_yellow = "#e6c384"; # carpYellow
      bright_green = "#87a987"; # dragonGreen
      bright_cyan = "#7aa89f"; # waveAqua2
      bright_blue = "#7fb4ca"; # springBlue
      bright_magenta = "#938aa9"; # springViolet1
    };
  };
}
