# modules/ui/style/network.nix
# programs.sarisarinama.style.network: the look of the network panel.
# Geometry only; colours are theme.surfaces.network. The font and spacing
# keys override the shared ones; null inherits them. The card, switch,
# pills and rows are every panel's, from _lib/panel.nix.
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
    options.programs.sarisarinama.style.network =
      shared "network panel"
      // panel
      // {
        stats = {
          columnGap = px 20 "Least gap between a label and its value.";
          rowGap = px 4 "Gap between the rows of the stats.";
          step = lib.mkOption {
            type = lib.types.enum ["caption" "body" "title" "heading"];
            default = "body";
            description = "Step of the panel's type scale the stats use.";
          };
          fontSize = lib.mkOption {
            type = lib.types.nullOr lib.types.ints.unsigned;
            default = null;
            description = "Absolute px size; overrides `step` when set.";
          };
        };

        field = {
          paddingX = px 8 "Horizontal padding inside the password field.";
          paddingY = px 6 "Vertical padding inside the password field.";
          radius = px 4 "Corner radius; not scaled.";
          border = px 1 "Border width; not scaled.";
        };
      };
  };
}
