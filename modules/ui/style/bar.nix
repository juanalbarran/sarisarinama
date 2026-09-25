# modules/ui/style/bar.nix
# programs.sarisarinama.style.bar: the look of the bar and of every widget
# in it. Over 60 lines on purpose: one file per component, divided into the
# general bar and one block per widget, is easier to read than six files.
#
# Every widget shares the bar's font, which is style.font unless the keys
# from _lib/shared.nix override it. A widget names a step of that scale, so
# moving the size moves the bar; `fontSize` pins one widget in px.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    shared = import ./_lib/shared.nix lib;
    px = default: description:
      lib.mkOption {
        type = lib.types.ints.unsigned;
        inherit default description;
      };

    # The text options every widget has. `step` picks from the type scale.
    text = default: {
      step = lib.mkOption {
        type = lib.types.enum ["caption" "body" "title" "heading"];
        inherit default;
        description = "Step of the type scale this widget's text uses.";
      };
      fontSize = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.unsigned;
        default = null;
        description = "Absolute px size; overrides `step` when set.";
      };
    };
  in {
    options.programs.sarisarinama.style.bar =
      shared "bar"
      // {
        # General bar
        height = px 30 "Bar height in design px.";
        paddingLeft = px 40 "Space between the screen edge and the workspaces.";
        paddingRight = px 20 "Space between the last widget and the screen edge.";
        spacing = px 10 "Gap between the service widgets on the right.";

        # Clock, in the centre
        clock = text "title";

        # Workspaces, on the left
        workspaces =
          text "caption"
          // {
            spacing = px 7 "Gap between workspace indicators.";
            paddingX = px 2 "Horizontal padding around one indicator.";
            animation = lib.mkOption {
              type = lib.types.ints.unsigned;
              default = 300;
              description = "Color fade in ms when a workspace changes state.";
            };
          };

        # Service widgets, on the right
        audio = text "body";
        battery = text "body";
        network = text "body";

        # The tray draws icons, not text, so it has no step
        tray = {
          iconSize = px 16 "Tray icon size in design px.";
          spacing = px 8 "Gap between tray icons.";
        };
      };
  };
}
