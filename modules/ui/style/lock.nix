# modules/ui/style/lock.nix
# programs.sarisarinama.style.lock: the look of the lock screen.
# Geometry only; colours are theme.surfaces.lock. The font and spacing
# keys override the shared ones; null inherits them. Not a panel: no card,
# a whole screen with the time and one field.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    shared = import ./_lib/shared.nix lib;
    px = default: description:
      lib.mkOption {
        type = lib.types.ints.unsigned;
        inherit default description;
      };
  in {
    options.programs.sarisarinama.style.lock =
      shared "lock screen"
      // {
        gap = px 16 "Gap between the time, the date and the field.";
        clockSize = px 72 "The time in px; display type, outside the type scale.";

        field = {
          width = px 320 "Password field width.";
          height = px 44 "Password field height.";
          paddingX = px 14 "Horizontal padding inside the field.";
          radius = px 8 "Corner radius; not scaled.";
          border = px 2 "Border width; not scaled.";
        };
      };
  };
}
