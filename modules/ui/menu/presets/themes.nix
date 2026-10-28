# modules/ui/menu/presets/themes.nix
# The themes menu, built when it opens rather than at build time: the shell
# already knows its own theme list, so the menu asks it instead of Nix
# writing the names twice. A family of themes (catppuccin-latte and
# catppuccin-mocha) is one row that reopens this menu with the family as
# `{arg}`, "" at the top (#52). {shell} is the running config path.
{
  flake.modules.homeManager.sarisarinama.programs.sarisarinama.menus.themes = {
    command = "qs -p {shell} ipc call theme entries {arg}";
  };
}
