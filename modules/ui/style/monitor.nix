# modules/ui/style/monitor.nix
# programs.sarisarinama.style.monitor: the look of the monitor panel.
# Geometry only; colours are theme.surfaces.monitor. The font and spacing
# keys override the shared ones; null inherits them. Every other key is a
# panel's own, from _lib/panel.nix: the monitor panel adds none.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    shared = import ./_lib/shared.nix lib;
    panel = import ./_lib/panel.nix lib;
  in {
    options.programs.sarisarinama.style.monitor = shared "monitor panel" // panel;
  };
}
