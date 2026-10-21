# modules/ui/menu/presets/main.nix
# The root menu: what the shell opens when summoned without a file. Kept
# short: the panels are under Services (services.nix). Projects, bookmarks,
# wallpapers and keybinds have menus of their own but no row here; a config
# reaches them through its own keybinds.
{
  flake.modules.homeManager.sarisarinama.programs.sarisarinama.menus.root = [
    {
      icon = "󰀻 ";
      label = "Applications";
      menu = "applications";
    }
    {
      icon = "󰏘 ";
      label = "Themes";
      menu = "themes";
    }
    {
      icon = "󰒋 ";
      label = "Services";
      menu = "services";
    }
    {
      icon = "󰒓 ";
      label = "System";
      menu = "system";
    }
  ];
}
