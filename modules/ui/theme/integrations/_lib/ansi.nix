# modules/ui/theme/integrations/_lib/ansi.nix
# The sixteen terminal colours, in index order, as palette keys: the mapping
# of omarchy's default/themed/foot.ini.tpl. Every terminal integration reads
# it, so foot and tmux never disagree on what colour 4 is.
[
  "background"
  "red"
  "green"
  "yellow"
  "blue"
  "magenta"
  "cyan"
  "foreground"

  "muted"
  "bright_red"
  "bright_green"
  "bright_yellow"
  "bright_blue"
  "bright_magenta"
  "bright_cyan"
  "bright_foreground"
]
