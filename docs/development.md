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

## Gotchas

- Untracked files are invisible to `nix build .`; use `path:.` or `git add`.
- `IpcHandler` needs `import Quickshell.Io`; `Loader` needs `import QtQuick`.
- `qml`/`qmllint` cannot resolve QtQuick. To check QML headlessly, run
  `timeout 8 qs -p <dir>` on a windowless `ShellRoot`.
- A singleton loads its `FileView` when first touched: a probe reading tokens
  in that same tick still sees defaults.
- `pkgs.system` is deprecated; use `pkgs.stdenv.hostPlatform.system`.
