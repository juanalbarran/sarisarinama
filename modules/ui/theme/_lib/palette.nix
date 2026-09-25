# modules/ui/theme/_lib/palette.nix
# The cascade of omarchy's bin/omarchy-theme-color, ported. Takes a raw
# palette — semantic names, the legacy short names, or ANSI color0..color15
# — and returns the semantic names only, every one resolved. Binding order
# is the script's order: a later key may read one an earlier line filled in.
lib: let
  inherit (import ./mix.nix lib) mix isLight;
in
  raw: let
    # bash's [[ ${x} ]]: unset and empty are the same thing.
    get = k:
      if (raw.${k} or "") != ""
      then raw.${k}
      else null;
    first = lib.findFirst (v: v != null) null;

    # Canonical names beat the legacy short ones; ANSI comes last.
    background = first [(get "background") (get "bg") (get "color0")];
    foreground = first [(get "foreground") (get "fg") (get "color7")];

    # The script writes background/foreground back into color0/color7
    # before the fallbacks below read them.
    color0 = first [background (get "color0")];
    color7 = first [foreground (get "color7")];
    color8 = get "color8";

    red = first [(get "red") (get "color1")];
    green = first [(get "green") (get "color2")];
    yellow = first [(get "yellow") (get "color3")];
    blue = first [(get "blue") (get "color4")];
    cyan = first [(get "cyan") (get "color6")];
    magenta = first [(get "magenta") (get "color5") (get "purple")];

    light_foreground = first [(get "light_foreground") (get "light_fg") color7];
    bright_foreground = first [(get "bright_foreground") (get "bright_fg") (get "color15") foreground];
    lighter_background = first [(get "lighter_background") (get "lighter_bg") color0];
    dark_foreground = first [(get "dark_foreground") (get "dark_fg") color8 foreground];
    muted = first [(get "muted") color8 dark_foreground];
    selection = first [(get "selection") (get "selection_background") color8 color0];
    orange = first [(get "orange") yellow];

    # Everything below is arithmetic, never a foreign key.
    shade = k: legacy: base: amount: target:
      first [(get k) (get legacy) (mix base target amount)];
    bright = k: ansi: base:
      first [(get "bright_${k}") (get ansi) (mix base "#ffffff" 0.2)];
  in {
    inherit
      background
      foreground
      light_foreground
      bright_foreground
      lighter_background
      dark_foreground
      muted
      selection
      red
      green
      yellow
      blue
      cyan
      magenta
      orange
      ;

    # omarchy leaves `accent` to the theme; falling back to foreground
    # keeps the rendered JSON well formed when one does not declare it.
    accent = first [(get "accent") foreground];

    mode = first [
      (get "mode")
      (get "theme_type")
      (
        if isLight background
        then "light"
        else "dark"
      )
    ];

    dark_background = shade "dark_background" "dark_bg" background 0.25 "#000000";
    darker_background = shade "darker_background" "darker_bg" background 0.5 "#000000";
    brown = first [(get "brown") (mix orange "#000000" 0.5)];

    bright_red = bright "red" "color9" red;
    bright_green = bright "green" "color10" green;
    bright_yellow = bright "yellow" "color11" yellow;
    bright_blue = bright "blue" "color12" blue;
    bright_cyan = bright "cyan" "color14" cyan;
    bright_magenta = first [(get "bright_magenta") (get "color13") (get "bright_purple") (mix magenta "#ffffff" 0.2)];
  }
