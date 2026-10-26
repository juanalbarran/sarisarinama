# modules/ui/menu/_lib/projects.sh
# One directory, rendered as the project menu's rows.
#
# A subdirectory holding any marker is a project: its row launches it and the
# menu closes. Anything else is a branch: its row reopens this same menu one
# level down, so the same test runs again at every level.
#
# Rows most opened come first: a project counts the times it was opened, a
# branch the opens of every project inside it. Ties go to the one opened
# last, then name order. The opens are what open-project.sh logged.

dir="${1:-}"
dir="${dir:-${SARISARINAMA_PROJECTS_ROOT:-$HOME/dev}}"
dir="${dir/#\~/$HOME}"
# Spelled as open-project.sh logs it, so the paths compare equal
dir="$(realpath -s -- "$dir")"
menu="${SARISARINAMA_PROJECTS_MENU:-$HOME/.config/sarisarinama/projects.json}"
opened="${XDG_STATE_HOME:-$HOME/.local/state}/sarisarinama/projects-opened"

# One "<kind><tab><name>" line per subdirectory, then a single jq builds
# every row: one jq per row was most of the time the menu took to open
while IFS= read -r name; do
    if is_project "$dir/$name"; then
        printf 'project\t%s\n' "$name"
    else
        printf 'branch\t%s\n' "$name"
    fi
done < <(find "$dir" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -printf '%f\n' | sort) |
    jq -Rnc --arg d "$dir" --arg m "$menu" \
        --rawfile log <(cat -- "$opened" 2>/dev/null || true) '
        ($log | split("\n") | to_entries) as $opens
        | [inputs] | to_entries | map(
            (.value | index("\t")) as $tab
            | (.value[:$tab]) as $kind
            | (.value[$tab + 1:]) as $name
            | ($d + "/" + $name) as $p
            # Where in the log each open of this row is, oldest first
            | [$opens[] | select(.value == $p or (.value | startswith($p + "/"))) | .key] as $at
            | {
                order: .key,
                uses: ($at | length),
                last: ($at | max // -1),
                row: (if $kind == "project"
                    then {icon: "", label: $name, action: ("sarisarinama-open-project " + ($p | @sh))}
                    else {icon: "", label: $name, menu: $m, arg: $p}
                    end)
            })
        | sort_by(-.uses, -.last, .order) | map(.row)'
