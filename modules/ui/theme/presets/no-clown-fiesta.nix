# modules/ui/theme/presets/no-clown-fiesta.nix
# aktersnurra/no-clown-fiesta.nvim, `dark` variant, with a darker
# background than upstream's #151515. Its own `accent` (#202020) is a
# surface, not a hue, so the menu border takes `blue` instead. Everything
# the cascade can derive is left out: see themes.md.
{
  flake.modules.homeManager.sarisarinama = {
    programs.sarisarinama.theme.palettes.no-clown-fiesta = {
      mode = "dark";

      # Darker than upstream #151515. Other steps tried:
      # "#101010" subtle, "#0a0a0a" near-black, "#000000" true black.
      background = "#0d0d0d";
      lighter_background = "#1a1a1a"; # ncf accent, the cursorline surface

      selection = "#181818";
      muted = "#373737"; # ncf gray: line numbers, borders

      # ncf blue, its one bright colour. Quieter options:
      # "#7e97ab" gray_blue, "#afafaf" light_gray (no hue at all).
      accent = "#bad7ff";

      foreground = "#e1e1e1";
      dark_foreground = "#727272"; # ncf medium_gray, the comment colour

      red = "#b46958";
      yellow = "#f4bf75";
      orange = "#ffa557";
      green = "#90a959";
      cyan = "#88afa2";
      blue = "#bad7ff";
      magenta = "#aa759f";
    };
  };
}
