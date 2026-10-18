# modules/ui/menu/presets/main.nix
# The root menu: what the shell opens when summoned without a file.
{
  flake.modules.homeManager.sarisarinama.programs.sarisarinama.menus.root = [
    {
      icon = "󰀻 ";
      label = "Applications";
      menu = "applications";
    }
    {
      icon = "󰈮 ";
      label = "Projects";
      action = "sarisarinama-projects-menu";
    }
    {
      icon = "󰃀 ";
      label = "Bookmarks";
      menu = "bookmarks";
    }
    {
      icon = "󰖩 ";
      label = "Network";
      action = "qs -p \"$SARISARINAMA_PATH\" ipc call shell summon network '{}'";
    }
    {
      icon = "󰕾 ";
      label = "Sound";
      action = "qs -p \"$SARISARINAMA_PATH\" ipc call shell summon audio '{}'";
    }
    {
      icon = "󰏘 ";
      label = "Themes";
      menu = "themes";
    }
    {
      icon = "󰍹 ";
      label = "Monitors";
      action = "qs -p \"$SARISARINAMA_PATH\" ipc call shell summon monitor '{}'";
    }
    {
      icon = "󰒓 ";
      label = "System";
      menu = "system";
    }
  ];
}
