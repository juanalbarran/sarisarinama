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

The bar and the panels read these. Missing one does not fail; its widget
stays empty or wrong.

| Service               | Used by       | Without it                          |
| --------------------- | ------------- | ----------------------------------- |
| PipeWire              | `Audio.qml`   | no sink, the icon shows silence     |
| PipeWire              | audio panel   | no devices, no apps                 |
| UPower                | `Battery.qml` | no battery widget                   |
| UPower                | battery panel | the panel never opens               |
| power-profiles-daemon | battery panel | the profile pills change nothing    |
| NetworkManager        | `Network.qml` | `nmcli` fails, shows disconnected   |
| NetworkManager        | VPN panel     | `nmcli` fails, lists no profiles    |

UPower and power-profiles-daemon are system services, enabled in the NixOS
config, not here: `services.upower.enable` and
`services.power-profiles-daemon.enable`.

## Lock screen

The lock needs systemd's logind (Ubuntu and NixOS both have it), with
`busctl` and `systemd-inhibit` on `PATH`, and a PAM service; see
[lock](./lock.md#pam). On NixOS that means importing
`modules.nixos.sarisarinama`; elsewhere the Home Manager module writes it
with sudo on activation.

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
