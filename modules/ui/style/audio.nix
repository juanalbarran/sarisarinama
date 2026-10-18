# modules/ui/style/audio.nix
# programs.sarisarinama.style.audio: the look of the audio panel.
# Geometry only; colours are theme.surfaces.audio. The font and spacing
# keys override the shared ones; null inherits them. The card, switch and
# rows are every panel's, from _lib/panel.nix; the audio panel adds the
# volume slider.
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
    options.programs.sarisarinama.style.audio =
      shared "audio panel"
      // panel
      // {
        slider = {
          height = px 4 "Height of a volume slider's track; its ends are round.";
          knob = px 12 "Diameter of a volume slider's knob.";
        };
      };
  };
}
