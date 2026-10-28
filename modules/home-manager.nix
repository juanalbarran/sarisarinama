# modules/home-manager.nix
{self, ...}: {
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    # Quickshell with qtimageformats on its plugin path, so the image
    # viewer reads WebP and TIFF too. Same pkgs, so the same Qt. A binary
    # wrapper keeps argv[0], so `pkill -f '^quickshell -p'` still matches.
    quickshell = pkgs.symlinkJoin {
      name = "quickshell-${pkgs.quickshell.version}";
      paths = [pkgs.quickshell];
      nativeBuildInputs = [pkgs.makeBinaryWrapper];
      postBuild = ''
        for bin in qs quickshell; do
          wrapProgram $out/bin/$bin --prefix QT_PLUGIN_PATH : \
            ${pkgs.kdePackages.qtimageformats}/${pkgs.qt6.qtbase.qtPluginPrefix}
        done
      '';
    };
  in {
    options.programs.sarisarinama = {
      enable = lib.mkEnableOption "the sarisarinama desktop shell";

      package = lib.mkOption {
        type = lib.types.package;
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        description = "The Quickshell tree; SARISARINAMA_PATH points at its share/sarisarinama.";
      };
    };

    config = lib.mkIf cfg.enable {
      home.packages = [quickshell cfg.package];
      home.sessionVariables.SARISARINAMA_PATH = "${cfg.package}/share/sarisarinama";
    };
  };
}
