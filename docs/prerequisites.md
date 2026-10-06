# Prerequisites

What `sarisarinama` needs to run.

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

## Applications

The project menu launches these from `PATH`; the module installs none.

| Application            | Used for                                  |
| ---------------------- | ----------------------------------------- |
| `tmux`                 | every project session                     |
| `foot`                 | the default terminal, `projects.terminal` |
| `claude`               | the `agent` window                        |
| `nvim-base`            | the `editor` window, kukenan's `base`     |
| `devenv`               | projects with a `devenv.nix`              |
| `swaymsg` or `hyprctl` | focusing the terminal (the compositor's)  |
