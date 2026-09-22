# modules/ui/menu/presets/main.nix
# The root menu: what the shell opens when summoned without a file.
{
  flake.modules.homeManager.sarisarinama.programs.sarisarinama.menus.root = [
    {
      icon = "";
      label = "System";
      menu = "system";
    }
    {
      icon = "";
      label = "Projects";
      menu = "projects";
    }
  ];
}
