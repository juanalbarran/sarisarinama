# modules/ui/panes/network/status.nix
# The script behind the network panel's stats, sarisarinama-network-status,
# and the host it pings. What the panel contains lives here; how it looks
# is style.network and theme.surfaces.network.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    status = pkgs.writeShellApplication {
      name = "sarisarinama-network-status";
      # No iputils: its ping cannot send without the privilege the
      # system's own ping has, so the script takes ping from PATH.
      runtimeInputs = [pkgs.iproute2];
      runtimeEnv.SARISARINAMA_PING_HOST = cfg.network.pingHost;
      text = builtins.readFile ./_lib/network-status.sh;
    };
  in {
    options.programs.sarisarinama.network.pingHost = lib.mkOption {
      type = lib.types.str;
      default = "1.1.1.1";
      example = "9.9.9.9";
      description = ''
        Host the network panel pings, once every 1.5 s while it is open,
        for its ping and packet-loss figures.
      '';
    };

    config.home.packages = lib.mkIf cfg.enable [status];
  };
}
