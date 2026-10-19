# modules/ui/theme/wallpapers/render.nix
# Renders theme.wallpapers to ~/.config/sarisarinama/wallpapers.json: per
# theme, the image it starts with and every image it has, as store paths,
# and the rotation interval.
# Qt as packaged decodes jpg and png but not webp, which is what omarchy
# ships, so every other format is converted to JPEG here, once, at build
# time. The shell never scans a directory, as with theme.json.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;

    images = ["jpg" "jpeg" "png" "webp" "bmp" "gif"];
    native = ["jpg" "jpeg" "png"];
    extension = file: lib.toLower (lib.last (lib.splitString "." file));
    # The name a file has after conversion: native ones keep theirs.
    converted = file:
      if lib.elem (extension file) native
      then file
      else "${lib.removeSuffix ".${lib.last (lib.splitString "." file)}" file}.jpg";

    render = name: w: let
      files = lib.sort lib.lessThan (lib.filter (f: lib.elem (extension f) images)
        (lib.attrNames (lib.filterAttrs (_: type: type == "regular") (builtins.readDir w.directory))));
      out = pkgs.runCommand "sarisarinama-wallpapers-${name}" {nativeBuildInputs = [pkgs.imagemagick];} ''
        mkdir -p $out
        ${lib.concatMapStrings (f:
          if converted f == f
          then "cp ${w.directory + "/${f}"} $out/${lib.escapeShellArg f}\n"
          else "magick ${w.directory + "/${f}"} -quality 92 $out/${lib.escapeShellArg (converted f)}\n")
        files}
      '';
      start =
        if w.default == null
        then lib.head files
        else w.default;
    in {
      default = "${out}/${converted start}";
      all = map (f: "${out}/${converted f}") files;
    };
  in {
    config = lib.mkIf cfg.enable {
      assertions =
        lib.mapAttrsToList (name: w: {
          assertion = w.default == null || builtins.pathExists (w.directory + "/${w.default}");
          message = "programs.sarisarinama.theme.wallpapers.${name}.default: no file '${toString w.default}' in its directory.";
        })
        cfg.theme.wallpapers;

      xdg.configFile."sarisarinama/wallpapers.json".text = builtins.toJSON {
        rotate = cfg.theme.rotateWallpapers;
        themes = lib.mapAttrs render (lib.filterAttrs (_: w:
          builtins.any (f: lib.elem (extension f) images) (lib.attrNames (builtins.readDir w.directory)))
        cfg.theme.wallpapers);
      };
    };
  };
}
