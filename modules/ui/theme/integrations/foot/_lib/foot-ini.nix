# modules/ui/theme/integrations/foot/_lib/foot-ini.nix
# A resolved palette as foot's [colors-dark] section, mapped the way
# omarchy's default/themed/foot.ini.tpl maps it. foot wants rrggbb, no #.
lib: palette: let
  c = key: lib.removePrefix "#" palette.${key};
in ''
  [colors-dark]
  foreground=${c "foreground"}
  background=${c "background"}
  selection-foreground=${c "foreground"}
  selection-background=${c "selection"}
  cursor=${c "background"} ${c "bright_foreground"}

  regular0=${c "background"}
  regular1=${c "red"}
  regular2=${c "green"}
  regular3=${c "yellow"}
  regular4=${c "blue"}
  regular5=${c "magenta"}
  regular6=${c "cyan"}
  regular7=${c "foreground"}

  bright0=${c "muted"}
  bright1=${c "bright_red"}
  bright2=${c "bright_green"}
  bright3=${c "bright_yellow"}
  bright4=${c "bright_blue"}
  bright5=${c "bright_magenta"}
  bright6=${c "bright_cyan"}
  bright7=${c "bright_foreground"}
''
