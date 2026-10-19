# Development

Running the shell from the checkout, without activating the Home Manager
module. Option and file layout is in [nix.md](./nix.md).

## Loop

```
git add -A                      # flakes only see tracked files
nix build .#menus
ln -sfn "$(readlink -f result)/sarisarinama" ~/.config/sarisarinama
nix develop
qs -p ./quickshell              # terminal 1: the shell
```

Toggle a component from a second terminal. The handler is `shell`, the
component id is its key in the table in `shell.qml`, and an empty payload
means the root menu:

```
qs -p ./quickshell ipc call shell toggle menu '{}'
```

Remove that symlink before activating the real module; Home Manager will not
overwrite files it does not own.

The project menu calls three scripts that only the Home Manager module
installs, and talks to the shell at `$SARISARINAMA_PATH`. Before starting
`qs`, in both terminals: put the scripts on `PATH`, and
`export SARISARINAMA_PATH="$PWD/quickshell"`, then start the shell with
`qs -p "$SARISARINAMA_PATH"`. Quickshell tells the commands it runs
nothing about where it was started from.

The lock runs `sarisarinama-lock-events` the same way, from `PATH`; without
it the shell warns every 3 s and only `ipc call lock lock` and idle lock.
It reads `lock.json`, which `nix build .#menus` renders like the others.
Locking for real also needs `/etc/pam.d/sarisarinama-lock`, see
[lock](./lock.md#pam).

### Trying the lock without locking yourself out

A crash while locked keeps the screen locked, so try changes in a headless
Sway nested in the session, not in the session itself:

```
export XDG_RUNTIME_DIR=$(mktemp -d /run/user/$UID/sl.XXXX)
WLR_BACKENDS=headless WLR_RENDERER=pixman WLR_LIBINPUT_NO_DEVICES=1 \
  env -u SWAYSOCK -u WAYLAND_DISPLAY sway -c /dev/null &
WAYLAND_DISPLAY=wayland-1 qs -p ./quickshell
```

The directory must sit under `/run/user`: a longer path overflows the
socket name. `PamContext.configDirectory` points a test at a directory of
its own services (`auth required pam_permit.so`, `pam_deny.so`), so both
answers can be tried without a password.

## Gotchas

- Untracked files are invisible to `nix build .`; use `path:.` or `git add`.
- `IpcHandler` needs `import Quickshell.Io`; `Loader` needs `import QtQuick`.
- `qml`/`qmllint` cannot resolve QtQuick. To check QML headlessly, run
  `timeout 8 qs -p <dir>` on a windowless `ShellRoot`.
- A singleton loads its `FileView` when first touched: a probe reading tokens
  in that same tick still sees defaults.
- `pkgs.system` is deprecated; use `pkgs.stdenv.hostPlatform.system`.
