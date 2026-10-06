# modules/ui/menu/_lib/projects.sh
# One directory, rendered as the project menu's rows.
#
# A subdirectory holding any marker is a project: its row launches it and the
# menu closes. Anything else is a branch: its row reopens this same menu one
# level down, so the same test runs again at every level.

dir="${1:-}"
dir="${dir:-${SARISARINAMA_PROJECTS_ROOT:-$HOME/dev}}"
dir="${dir/#\~/$HOME}"
menu="${SARISARINAMA_PROJECTS_MENU:-$HOME/.config/sarisarinama/projects.json}"
{
    while IFS= read -r name; do
        if is_project "$dir/$name"; then
            jq -nc --arg l "$name" --arg p "$dir/$name" \
                '{icon:"", label:$l, action:("sarisarinama-open-project " + ($p|@sh))}'
        else
            jq -nc --arg l "$name" --arg p "$dir/$name" --arg m "$menu" \
                '{icon:"", label:$l, menu:$m, arg:$p}'
        fi
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -printf '%f\n' | sort)
} | jq -sc .
