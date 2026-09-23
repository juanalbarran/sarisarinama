# modules/ui/style/options.nix
# programs.sarisarinama.style: geometry and typography tokens, see
# docs/style.md. Defaults equal the ones in Style.qml, so leaving an option
# alone changes nothing. Colors are not here.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    px = default: description:
      lib.mkOption {
        type = lib.types.ints.unsigned;
        inherit default description;
      };
  in {
    options.programs.sarisarinama.style = {
      font = {
        family = lib.mkOption {
          type = lib.types.str;
          default = "JetBrains Mono Nerd Font";
          description = "Font family for every text in the shell.";
        };
        size = px 12 "Base font size in px; the type scale derives from it.";
      };

      spacing.scale = lib.mkOption {
        type = lib.types.numbers.positive;
        default = 1.0;
        description = "Multiplies every length token; 1.0 keeps design pixels.";
      };

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
