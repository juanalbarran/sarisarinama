# modules/ui/menu/_lib/raise-session.sh
# Run or raise for a tmux session, shared by open-project.sh and
# open-session.sh: one terminal serves every session. `raise_session <name>`
# focuses a terminal already showing the session; failing that, the last
# terminal used switches to it; only with no terminal at all is a new one
# opened.

# The terminal and the flags it needs before a command, e.g. "ghostty -e"
read -ra terminal <<<"${SARISARINAMA_TERMINAL:-foot}"

# Pids of the programs that own a window, one per line
window_pids() {
    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        hyprctl clients -j | jq '.[].pid'
    else
        swaymsg -t get_tree | jq '.. | objects | .pid? // empty'
    fi
}

focus() {
    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        hyprctl dispatch focuswindow "pid:$1" >/dev/null
    else
        swaymsg "[pid=$1] focus" >/dev/null
    fi
}

# The terminal running a tmux client: walking up the client's parents
# reaches it, whichever terminal that is, so no app-id flag (each terminal
# spells it differently) is needed. Prints its pid.
terminal_of() {
    local pids pid="$1"
    pids="$(window_pids)"
    while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
        if grep -qx "$pid" <<<"$pids"; then
            echo "$pid"
            return 0
        fi
        pid="$(ps -o ppid= -p "$pid" | tr -d ' ' || true)"
    done
    return 1
}

# client [list-clients flags]: the most recently used client that has a
# terminal on screen, as "<client name> <terminal pid>"
client() {
    local name pid term
    while read -r _ name pid; do
        if term="$(terminal_of "$pid")"; then
            echo "$name $term"
            return 0
        fi
    done < <(tmux list-clients "$@" \
        -F '#{client_activity} #{client_name} #{client_pid}' | sort -rn)
    return 1
}

raise_session() {
    local found
    if found="$(client -t "=$1")"; then
        focus "${found#* }"
    elif found="$(client)"; then
        tmux switch-client -c "${found% *}" -t "=$1"
        focus "${found#* }"
    else
        setsid "${terminal[@]}" tmux attach-session -t "=$1" \
            >/dev/null 2>&1 &
    fi
}
