# modules/ui/style/menu.nix
# programs.sarisarinama.style.menu: the look of the menu card and its rows.
# What the menu *contains* is modules/ui/menu; this is only geometry.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    px = default: description:
      lib.mkOption {
        type = lib.types.ints.unsigned;
        inherit default description;
      };
  in {
    options.programs.sarisarinama.style.menu = {
      card = {
        width = px 300 "Menu card width in design px.";
        padding = px 18 "Space between the card edge and its content.";
        radius = px 8 "Corner radius; not scaled.";
        border = px 1 "Border width; not scaled. 0 removes the border.";
      };

      row = {
        height = px 36 "Minimum menu row height in design px.";
        paddingX = px 12 "Horizontal padding inside a menu row.";
      };
    };
  };
}
