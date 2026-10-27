# modules/ui/menu/presets/applications.nix
# The applications menu: every installed desktop entry, the list
# `wofi --show drun` shows. The shell builds the rows itself, from
# Quickshell's DesktopEntries, so there is no command to run. An entry
# marked Terminal=true runs in the project menu's terminal. Remembered: the
# most opened apps come first.
{
  flake.modules.homeManager.sarisarinama = {config, ...}: {
    programs.sarisarinama.menus.applications = {
      source = "applications";
      inherit (config.programs.sarisarinama.projects) terminal;
    };
    programs.sarisarinama.remember = ["applications"];
  };
}
