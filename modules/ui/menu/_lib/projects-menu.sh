# modules/ui/menu/_lib/projects-menu.sh
# Entry point of the project menu: `sarisarinama-projects-menu [dir]`.
# A project skips the menu and opens straight in tmux. Anything else
# summons the menu at that directory, where projects.sh lists it.

dir="${1:-${SARISARINAMA_PROJECTS_ROOT:-$HOME/dev}}"
dir="${dir/#\~/$HOME}"
menu="${SARISARINAMA_PROJECTS_MENU:-$HOME/.config/sarisarinama/projects.json}"

if is_project "$dir"; then
    exec sarisarinama-open-project "$dir"
fi

# summon, not toggle: the point is to show this directory, even when the
# menu is already open on another one
exec qs -p "${SARISARINAMA_PATH:?the shell is not installed}" \
    ipc call shell summon menu \
    "$(jq -nc --arg f "$menu" --arg a "$dir" '{file: $f, arg: $a}')"
