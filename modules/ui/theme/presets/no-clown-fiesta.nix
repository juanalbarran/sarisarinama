# modules/ui/theme/presets/no-clown-fiesta.nix
# aktersnurra/no-clown-fiesta.nvim, `dark` variant (lua/no-clown-fiesta/
# palettes.lua), with a darker background than upstream's #151515. Every
# key is an upstream colour, mapped as its highlights.lua uses it (#46).
# Its own `accent` (#202020) is a surface, not a hue, so accent takes
# `blue` instead. Everything the cascade can derive is left out: see
# themes.md. The bright hues are derived, 20% into white: upstream has none.
{
  flake.modules.homeManager.sarisarinama = {
    programs.sarisarinama.theme.palettes.no-clown-fiesta = {
      mode = "dark";

      # Darker than upstream #151515. Other steps tried:
      # "#101010" subtle, "#0a0a0a" near-black, "#000000" true black.
      background = "#0d0d0d";
      lighter_background = "#171717"; # ncf alt_bg: CursorLine, floats

      selection = "#373737"; # ncf gray, Visual's background
      muted = "#373737"; # ncf gray: whitespace, borders

      # ncf blue, its one bright colour. Quieter options:
      # "#7e97ab" gray_blue, "#afafaf" light_gray (no hue at all).
      accent = "#bad7ff";

      foreground = "#e1e1e1";
      dark_foreground = "#727272"; # ncf medium_gray: comments, line numbers
      light_foreground = "#afafaf"; # ncf light_gray: menus, float borders

      red = "#b46958";
      yellow = "#f4bf75";
      orange = "#ffa557";
      green = "#90a959";
      cyan = "#88afa2";
      blue = "#bad7ff";
      magenta = "#aa759f";
    };

    # muted (#373737) is too dark for tmux's other window names and pane
    # borders on #0d0d0d; the comment colour reads there.
    programs.sarisarinama.integrations.tmux.roles.no-clown-fiesta.subtle = "dark_foreground";
  };
}
