# modules/ui/style/notifications.nix
# programs.sarisarinama.style.notifications: the look of the toasts and of
# the history panel. Geometry only; colours are theme.surfaces.notifications.
# The font and spacing keys override the shared ones; null inherits them.
# The panel's card, switch and rows are every panel's, from _lib/panel.nix,
# with a wider card; the toasts and the history list add their own.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    shared = import ./_lib/shared.nix lib;
    panel = import ./_lib/panel.nix lib;
    px = default: description:
      lib.mkOption {
        type = lib.types.ints.unsigned;
        inherit default description;
      };
    count = default: description:
      lib.mkOption {
        type = lib.types.ints.positive;
        inherit default description;
      };
  in {
    options.programs.sarisarinama.style.notifications =
      shared "notifications"
      // panel
      // {
        card =
          panel.card
          // {
            width = px 420 "History panel width in design px.";
          };

        toast = {
          width = px 380 "Toast width in design px.";
          padding = px 12 "Space between a toast's edge and its content.";
          gap = px 8 "Gap between one toast and the next.";
          margin = px 12 "Space between the toasts and the screen's top and right edges.";
          iconSize = px 40 "Size of a toast's icon.";
          radius = px 8 "Corner radius of a toast; not scaled.";
          border = px 2 "Border width of a toast; not scaled. 0 removes it.";
          bodyLines = count 3 "Lines of the body a toast shows before it is cut.";
          max = count 5 "Toasts on screen at once; the rest wait, not counting down.";
        };

        history = {
          maxHeight = px 420 "Past this height the history scrolls.";
          iconSize = px 28 "Size of an icon in the history.";
        };
      };
  };
}
