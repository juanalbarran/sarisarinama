# modules/ui/style/battery.nix
# programs.sarisarinama.style.battery: the look of the battery panel.
# Geometry only; colours are theme.surfaces.battery. The font and spacing
# keys override the shared ones; null inherits them. The card, pills and
# rows are every panel's, from _lib/panel.nix; the battery adds the
# charge bar.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    shared = import ./_lib/shared.nix lib;
    panel = import ./_lib/panel.nix lib;
    px = default: description:
      lib.mkOption {
        type = lib.types.ints.unsigned;
        inherit default description;
      };
  in {
    options.programs.sarisarinama.style.battery =
      shared "battery panel"
      // panel
      // {
        charge = {
          height = px 8 "Height of the charge bar; its ends are round.";
          animation = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = 320;
            description = "Fill slide in ms. A duration, not scaled.";
          };
        };
      };
  };
}
