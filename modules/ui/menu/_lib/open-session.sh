# modules/ui/menu/_lib/open-session.sh
# `sarisarinama-open-session <name>`: shows a running tmux session, run or
# raise as a project does (raise-session.sh, pasted above this file).

session="${1:?usage: sarisarinama-open-session <name>}"
unset TMUX

# The menu runs detached, so stderr goes nowhere: a failure says so on screen
if ! tmux has-session -t "=$session" 2>/dev/null; then
    notify-send --app-name=sarisarinama "$session" "The session is gone" || true
    exit 1
fi

raise_session "$session"
