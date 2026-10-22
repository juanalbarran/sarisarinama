# modules/ui/theme/integrations/tmux/_lib/tmux-conf.nix
# A resolved palette as tmux options. Panes get the theme's text,
# background, cursor and sixteen colours from tmux itself, so they look the
# same in any terminal and a switch repaints them without touching their
# programs. The bar and borders follow omarchy's config/tmux/tmux.conf:
# brightblack there is `muted` here, blue is `accent`.
lib: palette: let
  c = key: palette.${key};
  ansi = import ../../_lib/ansi.nix;
  # What a program reads to tell a dark terminal from a light one,
  # "foreground;background" as colour numbers, as omarchy sets it.
  colorfgbg =
    if palette.mode == "light"
    then "0;15"
    else "15;0";
in
  lib.concatLines (
    [
      ''set -g window-style "fg=${c "foreground"},bg=${c "background"}"''
      ''set -g cursor-colour "${c "bright_foreground"}"''
    ]
    ++ lib.imap0 (i: key: ''set -g pane-colours[${toString i}] "${c key}"'') ansi
    ++ [
      ''set -g status-style "fg=${c "foreground"},bg=${c "background"}"''
      ''set -g window-status-style "fg=${c "muted"}"''
      ''set -g window-status-current-style "fg=${c "accent"},bold"''
      ''set -g pane-border-style "fg=${c "muted"}"''
      ''set -g pane-active-border-style "fg=${c "accent"}"''
      ''set -g message-style "fg=${c "accent"},bg=${c "background"}"''
      ''set -g message-command-style "fg=${c "accent"},bg=${c "background"}"''
      ''set -g mode-style "fg=${c "foreground"},bg=${c "selection"}"''
      ''set -g clock-mode-colour "${c "accent"}"''
      ''set-environment -g COLORFGBG "${colorfgbg}"''
    ]
  )
