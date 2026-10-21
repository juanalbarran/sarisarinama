# modules/ui/menu/presets/services.nix
# The services menu: one row per panel that drives a system service. Each
# summons its panel, the same as a click on its bar icon.
let
  summon = pane: "qs -p \"$SARISARINAMA_PATH\" ipc call shell summon ${pane} '{}'";
in {
  flake.modules.homeManager.sarisarinama.programs.sarisarinama.menus.services = [
    {
      icon = "󰖩 ";
      label = "Network";
      action = summon "network";
    }
    {
      icon = "󰂯 ";
      label = "Bluetooth";
      action = summon "bluetooth";
    }
    {
      icon = "󰖂 ";
      label = "VPN";
      action = summon "vpn";
    }
    {
      icon = "󰍹 ";
      label = "Monitors";
      action = summon "monitor";
    }
    {
      icon = "󰕾 ";
      label = "Sound";
      action = summon "audio";
    }
  ];
}
