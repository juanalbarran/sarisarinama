# modules/ui/style/image.nix
# programs.sarisarinama.style.image: the look of the image viewer. Geometry
# only; colours are theme.surfaces.image. The font and spacing keys
# override the shared ones; null inherits them. The card keys, from
# _lib/panel.nix, draw the caption; the viewer adds its margin, zoom and pan.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    shared = import ./_lib/shared.nix lib;
    panel = import ./_lib/panel.nix lib;
    px = default: description:
      lib.mkOption {
        type = lib.types.ints.unsigned;
        inherit default description;
      };
    factor = default: description:
      lib.mkOption {
        type = lib.types.numbers.positive;
        inherit default description;
      };
  in {
    options.programs.sarisarinama.style.image =
      shared "image viewer"
      // panel
      // {
        margin = px 32 "Between the screen's edges, the image and the caption.";
        pan = px 80 "How far one H J K L press moves a zoomed image.";
        zoom = {
          step = factor 1.25 "One + or - press, or one wheel notch. A factor, not scaled.";
          max = factor 16 "The most the fitted image may be zoomed. A factor, not scaled.";
        };
        caption.maxWidth = px 900 "Past this a file name is cut in the middle.";
      };
  };
}
