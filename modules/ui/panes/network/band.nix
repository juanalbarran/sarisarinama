# modules/ui/panes/network/band.nix
# The script behind the network panel's band row,
# sarisarinama-network-band: reads the connected network's Wi-Fi band and
# pins it on that network's saved profile.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    band = pkgs.writeShellApplication {
      name = "sarisarinama-network-band";
      # No networkmanager: nmcli comes from PATH, so it is the one that
      # matches the NetworkManager actually running.
      runtimeInputs = [];
      text = builtins.readFile ./_lib/network-band.sh;
    };
  in {
    config.home.packages = lib.mkIf config.programs.sarisarinama.enable [band];
  };
}
