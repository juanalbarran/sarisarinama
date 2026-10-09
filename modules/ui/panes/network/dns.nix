# modules/ui/panes/network/dns.nix
# The network panel's DNS row: the providers it offers, and the script
# behind it, sarisarinama-network-dns, which sets them on the connected
# network's saved profile. DHCP, the servers the network hands out, is
# always offered first and is not in this list.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    dns = pkgs.writeShellApplication {
      name = "sarisarinama-network-dns";
      # No networkmanager: nmcli comes from PATH, so it is the one that
      # matches the NetworkManager actually running.
      runtimeInputs = [pkgs.iproute2];
      text = builtins.readFile ./_lib/network-dns.sh;
    };
    names = map (p: p.name) cfg.network.dnsProviders;
  in {
    options.programs.sarisarinama.network.dnsProviders = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Label on the DNS row.";
          };
          servers = lib.mkOption {
            type = lib.types.nonEmptyListOf lib.types.str;
            description = "IPv4 and IPv6 addresses, in the order to try them.";
          };
        };
      });
      default = [
        {
          name = "Cloudflare";
          servers = ["1.1.1.1" "1.0.0.1"];
        }
        {
          name = "Google";
          servers = ["8.8.8.8" "8.8.4.4"];
        }
      ];
      description = ''
        DNS providers the network panel offers after DHCP, in this order.
        Picking one sets its servers on the connected network only.
      '';
    };

    config = lib.mkIf cfg.enable {
      home.packages = [dns];
      assertions = [
        {
          assertion = !(lib.elem "DHCP" names);
          message = "network.dnsProviders: \"DHCP\" is always offered; do not list it.";
        }
        {
          assertion = lib.length (lib.unique names) == lib.length names;
          message = "network.dnsProviders: every name must be different.";
        }
      ];
    };
  };
}
