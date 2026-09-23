# Style

Geometry and typography of the UI, declared in Nix and read by the shell
from one file. Colors stay in `Colors.qml` (later `colors.json`); style
never holds a color. The same split as omarchy's `Commons/Style.qml` and
`Commons/Color.qml`; their tokens live in `default/themed/shell.toml.tpl`,
omanix renders that file from Nix in `lib/shell-toml.nix`.

## Contract (`~/.config/sarisarinama/style.json`)

One object with a section per concern. Every key has a default in
`Style.qml`, so a missing file or key still yields a usable shell.

```json
{
  "font": { "family": "JetBrains Mono Nerd Font", "size": 12 },
  "spacing": { "scale": 1.0 },
  "card": { "width": 300, "padding": 18, "radius": 8, "border": 1 },
  "row": { "height": 36, "paddingX": 12 }
}
```

Derived values, never declared:

- Type scale from `font.size`: caption ×0.833, body ×1, title ×1.167,
  heading ×1.333. Components ask `Style.font.body`, not a number.
- `Style.space(px)` multiplies a design pixel by `spacing.scale`.
- Menu row height is the larger of `row.height` and body + 2×`row.paddingX`.
- Card height is 2×`card.padding` + title + gap + rows, capped at 70% of
  the screen. Width is `card.width`. Nothing in `Menu.qml` is fixed.

## Files

| File                           | Role                                              |
| ------------------------------ | ------------------------------------------------- |
| `quickshell/theme/Style.qml`   | Singleton; FileView on `style.json`, defaults     |
| `quickshell/theme/qmldir`      | Registers `Colors` and `Style`                    |
| `modules/ui/style/options.nix` | `programs.sarisarinama.style.*` with defaults     |
| `modules/ui/style/render.nix`  | Writes `xdg.configFile."sarisarinama/style.json"` |

`preview.nix` collects every `xdg.configFile`, so `style.json` appears in
`nix build .#menus` without changes there. Radius and gaps are declared
here, not read from `hyprctl`: the shell also runs under Sway.

## Status

Planned. Steps, each leaving a working shell:

1. Size the menu to its rows with hardcoded constants in `Card.qml`.
2. Move the constants into `Style.qml` with the defaults above.
3. Add the Nix options and render `style.json`; `Style.qml` reads it.
4. Bar widgets switch from literal fonts and paddings to `Style` tokens.

Open: whether `Colors.qml` moves to a rendered `colors.json` in the same
module or in a separate `theme` module.
