# modules/ui/theme/surfaces.nix
# programs.sarisarinama.theme.surfaces: which palette key paints what. A
# value names a key of themes/<name>.json, or is a literal "#rrggbb".
# The [bar] and [menu] sections of omarchy's default/themed/shell.toml.tpl,
# without its [hyprland] indirection: this shell also runs under Sway, so
# borders point straight at accent. One block per component that exists.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
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
    options.programs.sarisarinama.theme.surfaces = {
      bar = {
        background = key "background" "The bar panel itself.";
        backgroundAlpha = alpha 1.0 "0 is invisible, 1 opaque.";
        text = key "foreground" "A widget at rest.";
        focused = key "accent" "The focused workspace.";
        hover = key "yellow" "A widget under the pointer.";
        urgent = key "red" "A widget calling attention to itself:
          omarchy's [bar] active, split by state.";
      };

      menu = {
        background = key "background" "The card behind the rows.";
        backgroundAlpha = alpha 1.0 "0 is invisible, 1 opaque.";
        text = key "foreground" "An unselected row.";
        title = key "accent" "The card title. Not an omarchy token: the
          card shows the menu file name, see menu.md.";
        border = key "accent" "Card border. omarchy takes this from the
          Hyprland gradient; accent is the Sway-safe equivalent.";
        borderAlpha = alpha 1.0 "0 is invisible, 1 opaque.";
        selectedBackground = key "foreground" "Fill behind the current row.";
        selectedBackgroundAlpha = alpha 0.08 "A wash, not a block.";
        selectedText = key "accent" "The current row's text.";
      };
    };
  };
}
