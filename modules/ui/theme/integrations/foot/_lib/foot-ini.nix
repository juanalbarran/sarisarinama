# modules/ui/theme/integrations/foot/_lib/foot-ini.nix
# A resolved palette as foot's [colors-dark] section, mapped the way
# omarchy's default/themed/foot.ini.tpl maps it. foot wants rrggbb, no #.
lib: palette: let
  c = key: lib.removePrefix "#" palette.${key};
  ansi = import ../../_lib/ansi.nix;
  # regular0..7 are the first eight of the sixteen, bright0..7 the rest.
  entries = prefix: keys:
    lib.concatImapStrings (i: key: "${prefix}${toString (i - 1)}=${c key}\n") keys;
in ''
  [colors-dark]
  foreground=${c "foreground"}
  background=${c "background"}
  selection-foreground=${c "foreground"}
  selection-background=${c "selection"}
  cursor=${c "background"} ${c "bright_foreground"}

  ${entries "regular" (lib.take 8 ansi)}
  ${entries "bright" (lib.drop 8 ansi)}''
