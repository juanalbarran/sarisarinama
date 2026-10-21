# modules/ui/panes/bluetooth/scripts.nix
# The scripts behind the Bluetooth panel: sarisarinama-bluetooth-power turns
# the radio on or off through rfkill, sarisarinama-bluetooth-device pairs,
# connects, disconnects or forgets a device through bluetoothctl.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # No bluez, no util-linux: bluetoothctl and rfkill come from PATH, so
    # they are the ones that match the BlueZ actually running.
    script = name:
      pkgs.writeShellApplication {
        name = "sarisarinama-bluetooth-${name}";
        runtimeInputs = [];
        text = builtins.readFile ./_lib/bluetooth-${name}.sh;
      };
  in {
    config.home.packages = lib.mkIf config.programs.sarisarinama.enable [
      (script "power")
      (script "device")
    ];
  };
}
