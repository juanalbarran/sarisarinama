# Image viewer

An image, fitted to the screen over a dimmed desktop, with its name, its
place in its folder, its size and the zoom in a caption under it. `h` and
`l` step to the other images in the same folder. It is the default
application for images, so `xdg-open` and Yazi open a picture here instead
of in the browser.

```
sarisarinama-image ~/Pictures/photo.jpg
qs -p $SARISARINAMA_PATH ipc call shell summon image '{"path": "/abs/photo.jpg"}'
```

## How a file gets here

Omarchy quattro does not draw images in its shell: it lists `imv.desktop`
as the default for every `image/*` type in its `mimeapps.list`. The viewer
takes the same route to a shell pane of its own:

1. `xdg-open` (Yazi's default opener) asks `mimeapps.list` for the type's
   default: `sarisarinama-image.desktop`.
2. The desktop entry runs `sarisarinama-image <file>`.
3. The script makes the path absolute and summons the `image` component
   with `{"path": …}`. It is `summon`, not `toggle`: a second image
   replaces the one in view.

`modules/ui/panes/image/viewer.nix` writes the desktop entry and the
`xdg.mimeApps.defaultApplications` lines. Home Manager writes
`mimeapps.list` only where `xdg.mimeApps.enable` is set; canaima sets it in
`default-browser.nix`. `programs.sarisarinama.image.enable = false` leaves
images to whatever claimed them before.

The shell has to be running: the script only talks to it over IPC, like
every other summon.

## Formats

| Type       | Decoded by                                    |
| ---------- | --------------------------------------------- |
| PNG, JPEG  | Qt                                            |
| GIF        | Qt; played with `AnimatedImage`               |
| BMP, ICO   | Qt                                            |
| SVG        | qtsvg, already in Quickshell's wrapper        |
| WebP, TIFF | `qtimageformats`, put there by the HM module  |

Quickshell's own wrapper carries only Qt's built-in image plugins. The
Home Manager module installs Quickshell wrapped once more, with
`kdePackages.qtimageformats` on `QT_PLUGIN_PATH`, from the same `pkgs`
and so the same Qt. The wrapper is a binary one: a shell wrapper would turn
`argv[0]` into a store path, and canaima's
`pkill -f '^quickshell -p …'` would stop finding the shell. The dev shell
sets the same `QT_PLUGIN_PATH`. AVIF, HEIF and JPEG XL would take
`kdePackages.kimageformats`; they are not registered.

The folder is read with `FolderListModel`, filtered on the extensions above
(`imagemodel.js`), sorted by name, case-insensitively, hidden files
included. A file that cannot be decoded still takes its place in the folder
and its caption says `CANNOT READ THIS FILE`.

## Keys

| Key                          | Does                                     |
| ---------------------------- | ---------------------------------------- |
| `l` / `n` / `→` / `Space`    | Next image in the folder, wrapping round |
| `h` / `p` / `←` / `Backspace`| Previous image                           |
| `g` / `Home`, `G` / `End`    | First, last image                        |
| `+` / `=`, `-`, mouse wheel  | Zoom in, out, by `style.image.zoom.step` |
| `0`                          | Back to the fit                          |
| `1`                          | One file pixel per screen pixel, or back |
| `H` `J` `K` `L`, drag        | Pan a zoomed image                       |
| `i`                          | Hide or show the key hints               |
| `q` / `Esc`                  | Close                                    |

Zoom 1 is the fit, never less: zooming out stops there. A small image is
not blown up to fit, it is shown at its own size. An uppercase letter is
either the text typed or Shift with the key, so `H` pans whichever the
keymap sends.

## Looks

`style.image` has every panel key from `_lib/panel.nix` (the caption is a
card), plus:

| Key                | Default | Meaning                                        |
| ------------------ | ------- | ---------------------------------------------- |
| `margin`           | 32      | Screen edge to image, and to the caption       |
| `pan`              | 80      | One `H J K L` press                            |
| `zoom.step`        | 1.25    | A factor per press or wheel notch; not scaled  |
| `zoom.max`         | 16      | Most the fit may be zoomed; not scaled         |
| `caption.maxWidth` | 900     | Past this the file name is cut in the middle   |

`theme.surfaces.image` is a panel's block plus `backdrop` (`background`
at 0.92), the wash over the desktop.

## Files

| File                                       | Role                                                   |
| ------------------------------------------ | ------------------------------------------------------ |
| `quickshell/panes/image/ImagePanel.qml`    | Fullscreen PanelWindow; host contract, the keys        |
| `quickshell/panes/image/ImageState.qml`    | The path in view, its folder, next and previous        |
| `quickshell/panes/image/Viewport.qml`      | The image: fit, zoom, pan, GIFs played                 |
| `quickshell/panes/image/Caption.qml`       | Name, position, size, zoom, key hints                  |
| `quickshell/panes/image/imagemodel.js`     | Paths, URLs, extensions, fit and clamps; pure          |
| `quickshell/theme/ImageStyle.qml`          | `style.image`                                          |
| `quickshell/theme/ImageColors.qml`         | `theme.surfaces.image`                                 |
| `modules/ui/panes/image/viewer.nix`        | The script, the desktop entry, the mime defaults       |
| `modules/ui/panes/image/_lib/image-open.sh`| `sarisarinama-image`                                   |
| `modules/ui/style/image.nix`               | `style.image.*` options                                |

## Status

Tested headless under Sway with the Home Manager module's own wrapped
Quickshell. Verified: PNG, JPEG, WebP, TIFF and an animated GIF; a broken
file; a path with spaces, `#` and `?`; wrap-around, zoom, pan, fit and
actual size, the hints toggle and close; `xdg-open` reaching the viewer
through the rendered desktop entry and `mimeapps.list`. Not yet used on a
real screen or under Hyprland, and not yet opened from Yazi itself.
