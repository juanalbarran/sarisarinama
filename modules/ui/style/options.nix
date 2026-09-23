# modules/ui/style/options.nix
# programs.sarisarinama.style: what every component shares, see docs/style.md.
# Per-component looks live beside this file: bar.nix, menu.nix. Colors are
# not here. Defaults equal the ones in quickshell/theme/Style.qml.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: {
    options.programs.sarisarinama.style = {
      font = {
        family = lib.mkOption {
          type = lib.types.str;
          default = "JetBrains Mono Nerd Font";
          description = "Font family for every text in the shell.";
        };
        size = lib.mkOption {
          type = lib.types.ints.unsigned;
          default = 12;
          description = ''
            Base font size in px. The type scale derives from it:
            caption x0.833, body x1, title x1.167, heading x1.333.
          '';
        };
      };

      spacing.scale = lib.mkOption {
        type = lib.types.numbers.positive;
        default = 1.0;
        description = "Multiplies every length token; 1.0 keeps design pixels.";
      };
    };
  };
}
