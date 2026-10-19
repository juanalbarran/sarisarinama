# modules/ui/lock/events.nix
# sarisarinama-lock-events, the script the lock runs to hear logind:
# `loginctl lock-session` (the system menu's Lock) and an imminent suspend.
# dbus-monitor is Nix's; busctl and systemd-inhibit come from PATH.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    events = pkgs.writeShellApplication {
      name = "sarisarinama-lock-events";
      runtimeInputs = [pkgs.dbus];
      text = builtins.readFile ./_lib/lock-events.sh;
    };
  in {
    config.home.packages = lib.mkIf cfg.enable [events];
  };
}
