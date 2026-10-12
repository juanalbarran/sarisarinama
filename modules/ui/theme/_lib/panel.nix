# modules/ui/theme/_lib/panel.nix
# The surfaces every panel shares: the card, its text, the switch, the
# pills and the list rows. A panel's block in surfaces.nix is these plus
# its own keys, so the common components in quickshell/panes/common/ paint
# the same tokens in any panel. Under _lib/, so import-tree does not read
# it as a module.
lib: let
  key = default: description:
    lib.mkOption {
      type = lib.types.str;
      inherit default description;
    };
  alpha = default: description:
    lib.mkOption {
      type = lib.types.numbers.between 0.0 1.0;
      inherit default description;
    };
in {
  background = key "background" "The panel card.";
  backgroundAlpha = alpha 1.0 "0 is invisible, 1 opaque.";
  border = key "accent" "Panel border, like the menu's.";
  borderAlpha = alpha 1.0 "0 is invisible, 1 opaque.";
  text = key "foreground" "Names and values.";
  muted = key "dark_foreground" "State lines and headings.";
  accent = key "accent" "A switch when on, the pill in force.";
  track = key "muted" "A switch when off.";
  urgent = key "red" "Something failed or needs attention.";
  separator = key "muted" "The line between the panel's sections.";
  hover = key "foreground" "Fill behind the row or pill under the pointer.";
  hoverAlpha = alpha 0.08 "A wash, not a block.";
  current = key "accent" "Fill behind the row or pill in force.";
  currentAlpha = alpha 0.10 "A wash, not a block.";
  cursor = key "accent" "The keyboard ring.";
}
