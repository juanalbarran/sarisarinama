# modules/ui/theme/integrations/tmux/_lib/theme-tmux.sh
# sarisarinama-theme-tmux [name]: paints tmux with a theme. The theme's
# tmux.conf is copied to the file tmux's config sources, for servers started
# from now on, and sourced into the running server, which repaints at once.
# No name means the theme in use. Ported from omarchy's
# omarchy-theme-set-tmux, which pushes OSC sequences into every pane; here
# pane-colours does that job from the copy.

# install, not cp: the source is read-only in the Nix store.
install -Dm644 "$config/tmux/$name.conf" "$state/tmux.conf"

# No server, nothing to repaint; source-file would start one.
tmux has-session 2>/dev/null || exit 0

tmux source-file "$state/tmux.conf"

# The options apply at once, but text already on screen keeps its old
# colours until its client redraws.
while read -r client; do
  tmux refresh-client -t "$client" 2>/dev/null || true
done < <(tmux list-clients -F '#{client_name}' 2>/dev/null || true)
