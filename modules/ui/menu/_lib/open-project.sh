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

# Several devenv shells starting at once race on .devenv/gc and one fails
# with "Failed to remove existing GC root". Building the env once, before
# any window, leaves the windows nothing to race over. Nothing is on screen
# yet, and a first build can take minutes, so a toast says what is going on
warm_devenv() {
    if [ -e "$dir/devenv.nix" ]; then
        notify "Building the devenv environment, the windows open when it is ready"
        (cd "$dir" && devenv shell true) >/dev/null 2>&1 ||
            notify "devenv shell failed; the windows will show why"
    fi
}

if ! tmux has-session -t "=$session" 2>/dev/null; then
    warm_devenv
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

# One line per open, read by projects.sh to put the most used rows first.
# Kept in the state dir, so it outlives a logout; only the last 1000 opens
# are kept, so old habits fade
opened="${XDG_STATE_HOME:-$HOME/.local/state}/sarisarinama/projects-opened"
mkdir -p "${opened%/*}"
realpath -s -- "$dir" >>"$opened"
tail -n 1000 -- "$opened" >"$opened.tmp" && mv -f -- "$opened.tmp" "$opened"

# Run or raise, one terminal for every project (raise-session.sh)
raise_session "$session"
