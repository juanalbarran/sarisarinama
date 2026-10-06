# modules/ui/menu/_lib/open-project.sh
# Opens one project in tmux: a session named after the directory with three
# windows, agent, editor and terminal, then a terminal window attached to it.
# Run or raise: one terminal serves every project, and a session is never
# built twice. A project with a .tmux-init.conf builds its own session: the
# file is a script that replaces the default windows.
#
# Each app is typed into its window's shell, not given as the window's
# command, so quitting it leaves a shell behind instead of closing the
# window. With a devenv.nix the app goes on the same line as `devenv shell`,
# so it can never start before the env has.

dir="${1:?usage: sarisarinama-open-project <dir>}"
dir="${dir/#\~/$HOME}"
# tmux turns . and : into _ in a session name; doing it here keeps the
# has-session lookup below pointed at the name tmux really created
session="$(basename "$dir" | tr '.:' '__')"
# The terminal and the flags it needs before a command, e.g. "ghostty -e"
read -ra terminal <<<"${SARISARINAMA_TERMINAL:-foot}"

# TMUX is set when the shell itself was started inside tmux. Inherited, it
# sends every call below to that server, and makes attach refuse to nest
# although the terminal is a separate window
unset TMUX

# The menu runs detached, so stderr goes nowhere: failures say so on
# screen instead
notify() {
    notify-send --app-name=sarisarinama "$session" "$1" || true
}
set -E
trap 'notify "Could not open the project (line $LINENO)"' ERR

# What gets typed into a window: the command, wrapped in devenv when present
line() {
    if [ -e "$dir/devenv.nix" ]; then
        echo "devenv shell${1:+ $1}"
    else
        echo "$1"
    fi
}

# window <name> <command>: appends a window, types the command into it.
# The first call creates the session, so the order of calls is the order
# of the windows.
window() {
    local id cmd
    if tmux has-session -t "=$session" 2>/dev/null; then
        id="$(tmux new-window -d -P -F '#{window_id}' \
            -t "=$session:" -n "$1" -c "$dir")"
    else
        id="$(tmux new-session -d -P -F '#{window_id}' \
            -s "$session" -n "$1" -c "$dir")"
    fi
    cmd="$(line "$2")"
    if [ -n "$cmd" ]; then
        tmux send-keys -t "$id" "$cmd" Enter
    fi
}

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

# The project's own setup, in place of the default windows: a bash script
# run with SESSION, selected_path and bash_path set, as canaima's
# projects.sh did, and it must create the session named $SESSION itself.
# Every line runs, and a failing one is reported. It runs in a bash of its
# own: an ERR trap never fires on the left of ||, nor anywhere inside it.
init() {
    # shellcheck disable=SC2016 # the $ belong to the inner bash
    SESSION="$session" selected_path="$dir" bash_path=bash \
        "$BASH" -c 'status=0; trap "status=\$?" ERR; . "$1"; exit "$status"' \
        init "$dir/.tmux-init.conf" ||
        notify "A command in .tmux-init.conf failed (exit $?)"
}

if ! tmux has-session -t "=$session" 2>/dev/null; then
    if [ -e "$dir/.tmux-init.conf" ]; then
        init
    else
        window agent claude
        window editor nvim-base
        window terminal ""
    fi
fi
if ! tmux has-session -t "=$session" 2>/dev/null; then
    notify ".tmux-init.conf did not create the session $session"
    exit 1
fi

# Run or raise, one terminal for every project: one already showing this
# session is raised; failing that, the last one used switches to it; only
# with no terminal at all is a new one opened
if found="$(client -t "=$session")"; then
    focus "${found#* }"
elif found="$(client)"; then
    tmux switch-client -c "${found% *}" -t "=$session"
    focus "${found#* }"
else
    setsid "${terminal[@]}" tmux attach-session -t "=$session" \
        >/dev/null 2>&1 &
fi
