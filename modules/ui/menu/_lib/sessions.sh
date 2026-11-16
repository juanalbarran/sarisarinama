# modules/ui/menu/_lib/sessions.sh
# `sarisarinama-sessions`: the running tmux sessions as menu rows, the one
# attached last first. Printed as a JSON array, so each row carries its own
# action with the session name quoted as one shell word: a name may hold
# spaces. No server running means no sessions: an empty menu, not an error.

# TMUX is set when the shell itself was started inside tmux; inherited, it
# would point every call at that server
unset TMUX

{ tmux list-sessions -F '#{session_last_attached} #{session_name}' 2>/dev/null || true; } |
    sort -rn |
    cut -d' ' -f2- |
    jq -Rnc '[inputs | {
        icon: "󰆍 ",
        label: .,
        action: ("sarisarinama-open-session " + @sh)
    }]'
