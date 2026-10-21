# modules/ui/style/bluetooth.nix
# programs.sarisarinama.style.bluetooth: the look of the Bluetooth panel.
# Geometry only; colours are theme.surfaces.bluetooth. The font and spacing
# keys override the shared ones; null inherits them. Every other key is a
# panel's own, from _lib/panel.nix: the Bluetooth panel adds none.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    shared = import ./_lib/shared.nix lib;
    panel = import ./_lib/panel.nix lib;
  in {
    options.programs.sarisarinama.style.bluetooth = shared "Bluetooth panel" // panel;
  };
}
