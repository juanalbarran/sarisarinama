# modules/ui/theme/wallpapers/options.nix
# programs.sarisarinama.theme.wallpapers: a directory of images per theme,
# and which of them the theme starts with. Every directory under the
# repository's wallpapers/ is picked up for the theme of the same name, so
# adding an image there is enough; a config may point a theme elsewhere.
# A family's directory holds one per flavor instead, named as the themes
# menu labels it: catppuccin/latte for catppuccin-latte, gruvbox/dark for
# gruvbox, the flavor named as the family, by its mode.
# theme.rotateWallpapers moves to the next image on a timer.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    ...
  }: let
    root = ../../../../wallpapers;
    resolve = import ../_lib/palette.nix lib;
    palettes = config.programs.sarisarinama.theme.palettes;
    directories = path: lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir path));

    # A flavor's theme is family-flavor, unless only the family itself
    # exists and the flavor is its mode.
    themeOf = family: flavor:
      if !(palettes ? "${family}-${flavor}") && palettes ? ${family} && (resolve palettes.${family}).mode == flavor
      then family
      else "${family}-${flavor}";
    shipped = lib.listToAttrs (lib.concatMap (name: let
      flavors = directories (root + "/${name}");
    in
      if flavors == []
      then [(lib.nameValuePair name (root + "/${name}"))]
      else map (flavor: lib.nameValuePair (themeOf name flavor) (root + "/${name}/${flavor}")) flavors)
    (directories root));
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

    # Beside `wallpapers`, not in it: that one is keyed by theme name.
    options.programs.sarisarinama.theme.rotateWallpapers = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 0;
      example = 30;
      description = ''
        Minutes between moving to the theme's next wallpaper; 0 never does.
        omarchy has no rotation, so off by default.
      '';
    };

    config.programs.sarisarinama.theme.wallpapers =
      lib.mapAttrs (_: directory: {directory = lib.mkDefault directory;}) shipped;
  };
}
