# modules/ui/panes/image/_lib/image-open.sh
# sarisarinama-image <file>: shows the file in the shell's image viewer.
# The desktop entry runs it, so xdg-open (and Yazi through it) lands here.
# h and l in the viewer step to the other images in the file's folder, so
# one file is enough; any after the first are ignored.

if [ $# -eq 0 ]; then
  echo "usage: sarisarinama-image <file>" >&2
  exit 2
fi

# A file:// URI is left to the viewer, which decodes it; a plain path is
# made absolute here, since the shell does not share this directory.
case "$1" in
file://*) path="$1" ;;
*) path="$(realpath -- "$1")" ;;
esac

# summon, not toggle: a second image replaces the one in view
exec qs -p "${SARISARINAMA_PATH:?the shell is not installed}" \
  ipc call shell summon image "$(jq -nc --arg p "$path" '{path: $p}')"
