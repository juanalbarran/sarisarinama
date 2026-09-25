# modules/ui/menu/presets/themes.nix
# The themes menu, built when it opens rather than at build time: the shell
# already knows its own theme list, so the menu asks it instead of Nix
# writing the names twice. {shell} is the running config path, {} the line.
{
  flake.modules.homeManager.sarisarinama.programs.sarisarinama.menus.themes = {
    command = "qs -p {shell} ipc call theme list";
    icon = "󰏘";
    action = "qs -p {shell} ipc call theme set {}";
  };
}
