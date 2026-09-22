# Nix

## Flake outputs

- `packages.default`: the `quickshell/` tree copied to `share/sarisarinama`.
- `packages.menus`: the rendered menu JSON, for development without Home Manager.
- `modules.homeManager.sarisarinama`: the Home Manager module.
- `devShells.default`: quickshell and qt tooling.

`flake.modules.<class>.<name>` comes from `inputs.flake-parts.flakeModules.modules`,
imported in `flake.nix`. It merges definitions from many files into one module;
the default `flake.homeModules.x` is `unique raw` and cannot be split.

## Home Manager module

`programs.sarisarinama` options and where they live:

| Option                         | File                                 |
| ------------------------------ | ------------------------------------ |
| `enable`, `package`            | `modules/home-manager.nix`           |
| `menus` (attrsOf listOf entry) | `modules/ui/menu/options.nix`        |
| rendering + assertions         | `modules/ui/menu/render.nix`         |
| `systemMenu.*`                 | `modules/ui/menu/presets/system.nix` |

`render.nix` writes `xdg.configFile."sarisarinama/<name>.json"` per menu and
turns `menu = "system"` into the absolute path of `system.json`. Assertions:
exactly one of `action`/`menu` per entry, every referenced menu exists, a
`root` menu exists.

## Presets

One file per menu in `modules/ui/menu/presets/`, each a flake-parts module
adding to `flake.modules.homeManager.sarisarinama`. A value-only preset
assigns `...programs.sarisarinama.menus.<name> = [ ... ]`; a preset with its
own options is a function of `{config, lib, ...}` (see `system.nix`).
Dropping a file in the directory is enough; import-tree finds it.

## Development loop

```
git add -A                      # flakes only see tracked files
nix build .#menus
ln -sfn "$(readlink -f result)/sarisarinama" ~/.config/sarisarinama
nix develop
qs -p ./quickshell              # terminal 1
qs -p ./quickshell ipc call shell toggle menu '{"file":"~/.config/sarisarinama/root.json"}'
```

Remove that symlink before activating the real module; Home Manager will not
overwrite files it does not own.

## Gotchas

- Untracked files are invisible to `nix build .`; use `path:.` or `git add`.
- `IpcHandler` needs `import Quickshell.Io`; `Loader` needs `import QtQuick`.
- `qml`/`qmllint` in the devshell cannot resolve QtQuick. To check QML
  headlessly, run `timeout 8 qs -p <dir>` on a windowless `ShellRoot`.
- `pkgs.system` is deprecated; use `pkgs.stdenv.hostPlatform.system`.
