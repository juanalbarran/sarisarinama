# modules/ui/style/_lib/panel.nix
# The geometry every panel shares: the card, the hero row, the switch, the
# pills and the list rows. A panel's own options are these plus its own
# keys, so every panel reads the same names and the common components in
# quickshell/panes/common/ work in any of them. Under _lib/, so import-tree
# does not read it as a module.
lib: let
  px = default: description:
    lib.mkOption {
      type = lib.types.ints.unsigned;
      inherit default description;
    };
in {
  gap = px 12 "Gap between the sections of the panel.";

  card = {
    width = px 380 "Panel width in design px.";
    padding = px 18 "Space between the card edge and its content.";
    radius = px 8 "Corner radius; not scaled.";
    border = px 1 "Border width; not scaled. 0 removes the border.";
  };

  hero = {
    iconSize = px 32 "Size of the icon in the top row.";
    gap = px 14 "Gap between the icon, the labels and the switch.";
  };

  toggle = {
    width = px 36 "On/off switch width.";
    height = px 20 "On/off switch height; the knob fits inside it.";
    animation = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 120;
      description = "Knob slide in ms. A duration, not scaled.";
    };
  };

  pill = {
    paddingX = px 10 "Horizontal padding inside a pill.";
    paddingY = px 4 "Vertical padding inside a pill.";
    gap = px 6 "Gap between pills.";
    radius = px 4 "Corner radius of a pill; not scaled.";
  };

  list = {
    maxHeight = px 260 "Past this height a list scrolls.";
    spacing = px 4 "Gap between list rows, and under a row of pills' heading.";
  };

  row = {
    paddingX = px 10 "Horizontal padding inside a list row.";
    paddingY = px 6 "Vertical padding inside a list row.";
    gap = px 10 "Gap between a row's icon, its labels and what follows.";
    radius = px 6 "Corner radius of the row highlight; not scaled.";
  };
}
