# modules/ui/panes/monitor/scales.nix
# The scales the monitor panel offers for the focused display, one pill
# each. What the panel contains lives here; how it looks is style.monitor
# and theme.surfaces.monitor.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: {
    options.programs.sarisarinama.monitor.scales = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.numbers.positive;
      default = [1 1.25 1.5 2];
      example = [1 1.25 1.6 2 3];
      description = ''
        Scales the monitor panel offers for the focused display. Sway
        takes any; Hyprland may round one that does not divide the
        resolution evenly.
      '';
    };
  };
}
