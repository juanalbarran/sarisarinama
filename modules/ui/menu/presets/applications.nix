# modules/ui/menu/presets/applications.nix
# The applications menu: every installed desktop entry, the list
# `wofi --show drun` shows. The shell builds the rows itself, from
# Quickshell's DesktopEntries, so there is no command to run.
{
  flake.modules.homeManager.sarisarinama.programs.sarisarinama.menus.applications = {
    source = "applications";
  };
}
