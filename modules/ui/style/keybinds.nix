# modules/ui/style/keybinds.nix
# programs.sarisarinama.style.keybinds: the look of the keybinds pane.
# Geometry only; colours are theme.surfaces.keybinds. The font and spacing
# keys override the shared ones; null inherits them. The card and the pills
# are every panel's, from _lib/panel.nix, with a wider card: the binds sit
# in columns.
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
    options.programs.sarisarinama.style.keybinds =
      shared "keybinds pane"
      // panel
      // {
        card =
          panel.card
          // {
            width = px 820 "Pane width in design px.";
          };

        columns = {
          count = lib.mkOption {
            type = lib.types.ints.positive;
            default = 2;
            description = "Columns the groups are spread over.";
          };
          gap = px 28 "Gap between the columns.";
          groupGap = px 18 "Gap between one group of binds and the next in a column.";
          keysWidth = lib.mkOption {
            type = lib.types.numbers.between 0.1 0.9;
            default = 0.38;
            description = "Share of a column the keys take; the description gets the rest.";
          };
        };

        keycap = {
          paddingX = px 6 "Horizontal padding inside a keycap.";
          paddingY = px 2 "Vertical padding inside a keycap.";
          radius = px 4 "Corner radius of a keycap; not scaled.";
          depth = px 2 "Height of the keycap's lower edge, what makes it read as a key; not scaled.";
          gap = px 4 "Gap between the keys of a chord.";
          stepGap = px 10 "Gap between chords pressed one after the other.";
        };

        # The body scrolls past this share of the screen's height.
        maxHeight = lib.mkOption {
          type = lib.types.numbers.between 0.2 1.0;
          default = 0.75;
          description = "Largest share of the screen the pane takes before its binds scroll.";
        };
      };
  };
}
