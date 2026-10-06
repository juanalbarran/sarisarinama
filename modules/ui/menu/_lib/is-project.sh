
# modules/ui/menu/_lib/is-project.sh
# The project rule, read into every script that needs it: a directory
# holding any of these markers is a project, anything else is a branch.

is_project() {
    [ -e "$1/.git" ] || [ -e "$1/devenv.nix" ] || [ -e "$1/.gitignore" ] ||
        [ -e "$1/.tmux-init.conf" ] || [ -e "$1/agents.md" ]
}
