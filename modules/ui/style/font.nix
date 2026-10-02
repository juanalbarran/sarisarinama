# modules/ui/style/font.nix
# Installs the font that style.font.family names. The family is only a name
# fontconfig looks up; this is the package that puts the files on disk.
# Outside `style` on purpose: render.nix serializes that whole tree into
# style.json, and a package there would land in it as a store path.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
  in {
    options.programs.sarisarinama.fontPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.nerd-fonts.jetbrains-mono;
      defaultText = lib.literalExpression "pkgs.nerd-fonts.jetbrains-mono";
      description = ''
        Package that provides style.font.family; change both together.
        null installs nothing, for a font the system already has.
      '';
    };

    config = lib.mkIf (cfg.enable && cfg.fontPackage != null) {
      home.packages = [cfg.fontPackage];
      fonts.fontconfig.enable = lib.mkDefault true;
    };
  };
}
