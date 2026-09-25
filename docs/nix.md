# Nix

How the flake is put together and where every option lives. To run the
shell from the checkout, see [development.md](./development.md).

## Flake outputs

- `packages.default`: the `quickshell/` tree copied to `share/sarisarinama`.
- `packages.menus`: every rendered config file — the menus, `style.json`,
  `surfaces.json`, `theme.json` and one file per theme. Built by
  `modules/preview.nix`, which evaluates the Home Manager module outside
  Home Manager and stubs the options Home Manager would provide. Its config
  block is the only place this repo sets an option, so it is where to try
  one before it goes in the real config.
- `modules.homeManager.sarisarinama`: the Home Manager module.
- `devShells.default`: quickshell and qt tooling.

`flake.modules.<class>.<name>` comes from `inputs.flake-parts.flakeModules.modules`,
imported in `flake.nix`. It merges many files into one module; the default
`flake.homeModules.x` is `unique raw` and cannot be split.

## Home Manager module

A component's _content_ lives in its own module, its _looks_ are split in
two: `modules/ui/style/` holds geometry and type, `modules/ui/theme/` holds
color. So `modules/ui/menu/` says what the menu contains, `style/` how big
it is and `theme/` what it is painted with. There is no `modules/ui/bar/`.

| Option                                | File                                  |
| ------------------------------------- | ------------------------------------- |
| `enable`, `package`                   | `modules/home-manager.nix`            |
| `menus` (entries or a command)        | `modules/ui/menu/options.nix`         |
| menu rendering + assertions           | `modules/ui/menu/render.nix`          |
| `systemMenu.*`                        | `modules/ui/menu/presets/system.nix`  |
| `style.font`, `style.spacing`         | `modules/ui/style/options.nix`        |
| `style.<component>.font` and `.scale` | `modules/ui/style/_lib/shared.nix`    |
| `style.bar.*`                         | `modules/ui/style/bar.nix`            |
| `style.menu.*`                        | `modules/ui/style/menu.nix`           |
| `style` rendering                     | `modules/ui/style/render.nix`         |
| `theme.default`, `theme.palettes`     | `modules/ui/theme/options.nix`        |
| one palette per theme                 | `modules/ui/theme/presets/<name>.nix` |
| `theme.surfaces.*`                    | `modules/ui/theme/surfaces.nix`       |
| palette cascade (no options)          | `modules/ui/theme/_lib/`              |
| theme rendering + assertions          | `modules/ui/theme/render.nix`         |

The menu `render.nix` writes one `xdg.configFile."sarisarinama/<name>.json"`
per menu and turns `menu = "system"` into the path of `system.json`. It
asserts exactly one of `action`/`menu` per entry, no dangling reference and a
`root` menu — over the list-shaped menus only, since a command menu has no
entries to check. The style `render.nix` serializes the whole `style` tree
into `style.json`: two modules cannot define the same `xdg.configFile`,
which is why looks are one file and not one per component.

The theme `render.nix` is the exception that proves that rule: it writes a
whole directory, `themes/<name>.json` for every palette, because the shell
switches between them at runtime. It also writes `surfaces.json`, and
`theme.json` — the starting theme plus the list of every rendered name, so
the shell can validate a `theme set` without scanning a directory. It
asserts that `theme.default` names a palette. `current.json`, the theme in
use, is the shell's own file and is owned by nobody here.

## Presets

One file per menu in `modules/ui/menu/presets/`, and one per theme in
`modules/ui/theme/presets/`, each a flake-parts module adding to
`flake.modules.homeManager.sarisarinama`. A value-only preset assigns
`...menus.<name> = [ ... ]` or `...theme.palettes.<name> = { ... }`; one with
its own options is a function of `{config, lib, ...}` (see `system.nix`).
A menu preset may assign an object instead of a list — `{command, icon,
action}`, built when it opens; `themes.nix` is one. import-tree finds new
files, and ignores any path containing `/_`, which is how `theme/_lib/` and
`style/_lib/` stay plain functions, not modules.
