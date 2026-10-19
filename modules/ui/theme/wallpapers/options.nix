# modules/ui/theme/wallpapers/options.nix
# programs.sarisarinama.theme.wallpapers: a directory of images per theme,
# and which of them the theme starts with. Every directory under the
# repository's wallpapers/ is picked up for the theme of the same name, so
# adding an image there is enough; a config may point a theme elsewhere.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    root = ../../../../wallpapers;
    shipped = lib.filterAttrs (_: type: type == "directory") (builtins.readDir root);
  in {
    options.programs.sarisarinama.theme.wallpapers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          directory = lib.mkOption {
            type = lib.types.path;
            description = ''
              Images for this theme: jpg, png, webp, bmp or gif. Anything
              Qt cannot read on its own is converted to JPEG at build time.
            '';
          };
          default = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "1-winding-road.webp";
            description = ''
              File name, in `directory`, shown when the theme is selected;
              null takes the first by name, as omarchy does.
            '';
          };
        };
      });
      default = {};
      description = "Wallpapers per theme, keyed by theme name. A theme with none shows its background colour.";
    };

    config.programs.sarisarinama.theme.wallpapers =
      lib.mapAttrs (name: _: {directory = lib.mkDefault (root + "/${name}");}) shipped;
  };
}
