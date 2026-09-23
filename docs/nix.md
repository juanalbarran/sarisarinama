# Nix

How the flake is put together and where every option lives. To run the
shell from the checkout, see [development.md](./development.md).

## Flake outputs

- `packages.default`: the `quickshell/` tree copied to `share/sarisarinama`.
- `packages.menus`: every rendered config file, `style.json` included.
- `modules.homeManager.sarisarinama`: the Home Manager module.
- `devShells.default`: quickshell and qt tooling.

`flake.modules.<class>.<name>` comes from `inputs.flake-parts.flakeModules.modules`,
imported in `flake.nix`. It merges many files into one module; the default
`flake.homeModules.x` is `unique raw` and cannot be split.

## Home Manager module

A component's _content_ lives in its own module, its _looks_ in the style
module: `modules/ui/menu/` says what the menu contains, `modules/ui/style/`
how the menu and the bar look. There is no `modules/ui/bar/`.

| Option                         | File                                 |
| ------------------------------ | ------------------------------------ |
| `enable`, `package`            | `modules/home-manager.nix`           |
| `menus` (attrsOf listOf entry) | `modules/ui/menu/options.nix`        |
| menu rendering + assertions    | `modules/ui/menu/render.nix`         |
| `systemMenu.*`                 | `modules/ui/menu/presets/system.nix` |
| `style.font`, `style.spacing`  | `modules/ui/style/options.nix`       |
| `style.bar.*`                  | `modules/ui/style/bar.nix`           |
| `style.menu.*`                 | `modules/ui/style/menu.nix`          |
| `style` rendering              | `modules/ui/style/render.nix`        |

The menu `render.nix` writes one `xdg.configFile."sarisarinama/<name>.json"`
per menu and turns `menu = "system"` into the path of `system.json`. It
asserts exactly one of `action`/`menu` per entry, no dangling reference and
a `root` menu. The style `render.nix` serializes the whole `style` tree into
`style.json`: two modules cannot define the same `xdg.configFile`, which is
why looks are one file and not one per component.

## Presets

One file per menu in `modules/ui/menu/presets/`, each a flake-parts module
adding to `flake.modules.homeManager.sarisarinama`. A value-only preset
assigns `...menus.<name> = [ ... ]`; one with its own options is a function
of `{config, lib, ...}` (see `system.nix`). import-tree finds new files.
