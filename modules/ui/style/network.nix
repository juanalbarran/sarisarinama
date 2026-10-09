# modules/ui/style/network.nix
# programs.sarisarinama.style.network: the look of the network panel.
# Geometry only; colours are theme.surfaces.network. The font and spacing
# keys override the shared ones; null inherits them.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    shared = import ./_lib/shared.nix lib;
    px = default: description:
      lib.mkOption {
        type = lib.types.ints.unsigned;
        inherit default description;
      };
  in {
    options.programs.sarisarinama.style.network =
      shared "network panel"
      // {
        gap = px 12 "Gap between the sections of the panel.";

        card = {
          width = px 380 "Panel width in design px.";
          padding = px 18 "Space between the card edge and its content.";
          radius = px 8 "Corner radius; not scaled.";
          border = px 1 "Border width; not scaled. 0 removes the border.";
        };

        hero = {
          iconSize = px 32 "Size of the connection icon in the top row.";
          gap = px 14 "Gap between the icon, the labels and the switch.";
        };

        toggle = {
          width = px 36 "Wi-Fi switch width.";
          height = px 20 "Wi-Fi switch height; the knob fits inside it.";
          animation = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = 120;
            description = "Knob slide in ms. A duration, not scaled.";
          };
        };

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

        pill = {
          paddingX = px 10 "Horizontal padding inside a band or DNS pill.";
          paddingY = px 4 "Vertical padding inside a band or DNS pill.";
          gap = px 6 "Gap between pills.";
          radius = px 4 "Corner radius of a pill; not scaled.";
        };

        list = {
          maxHeight = px 260 "Past this height the network list scrolls.";
          spacing = px 4 "Gap between network rows.";
        };

        row = {
          paddingX = px 10 "Horizontal padding inside a network row.";
          paddingY = px 6 "Vertical padding inside a network row.";
          gap = px 10 "Gap between a row's icon, its labels and its lock.";
          radius = px 6 "Corner radius of the row highlight; not scaled.";
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
