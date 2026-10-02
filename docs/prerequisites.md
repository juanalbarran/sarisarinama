# Prerequisites

What `sarisarinama` needs to run. Anything marked _planned_ is not used by
the code yet.

## Operating system

Linux. NixOS is the target, through [canaima](https://github.com/juanalbarran/canaima).
Another distribution should work with Nix and Home Manager installed, but it
is untested: Qt programs from nixpkgs often need a GL wrapper there.

## Nix

The Nix package manager, with flakes enabled:

    experimental-features = nix-command flakes

## Home Manager

The flake exports a Home Manager module,
`modules.homeManager.sarisarinama`. It installs `quickshell` and the shell
itself, so neither is installed by hand. The development loop in
[development.md](./development.md) runs without it.

## Compositor

One of these two. Both are supported and the shell detects which one is
running.

- `Sway`: the default.
- `Hyprland`: the fancy one. Written, but never run against a real Hyprland,
  see [bar](./bar.md).

## Font

`JetBrains Mono Nerd Font`, the default of `style.font.family`. The module
installs it through `fontPackage`; set that to the package of whatever
family you pick, or `null` if the system already provides it. Every icon
in the bar and menu is a Nerd Font glyph, so without one they show as boxes.

## System services

The bar reads these. Missing one does not fail; its widget stays empty or
wrong.

| Service        | Used by       | Without it                        |
| -------------- | ------------- | --------------------------------- |
| PipeWire       | `Audio.qml`   | no sink, the icon shows silence   |
| UPower         | `Battery.qml` | no battery widget                 |
| NetworkManager | `Network.qml` | `nmcli` fails, shows disconnected |

## Applications (planned)

For the project menu; pinned in `flake.nix` or chosen, not wired yet.

- `herdr`: the multiplexer. Third-party, `github:herdrdev/herdr`, pinned
  at `v0.9.1`.
- `kukenan`: my neovim flake; the project menu opens its `base` flavor.
- `foot`: the default terminal.
- `ghostty`: the second terminal.
