# modules/ui/style/vpn.nix
# programs.sarisarinama.style.vpn: the look of the VPN panel.
# Geometry only; colours are theme.surfaces.vpn. The font and spacing
# keys override the shared ones; null inherits them. Every other key is a
# panel's own, from _lib/panel.nix: the VPN panel adds none.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    shared = import ./_lib/shared.nix lib;
    panel = import ./_lib/panel.nix lib;
  in {
    options.programs.sarisarinama.style.vpn = shared "VPN panel" // panel;
  };
}
