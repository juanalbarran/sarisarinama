# ./modules/devshell.nix
{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        quickshell
        qt6.qtdeclarative
      ];
      # What the Home Manager module's quickshell carries: WebP and TIFF
      # for the image viewer.
      QT_PLUGIN_PATH = "${pkgs.kdePackages.qtimageformats}/${pkgs.qt6.qtbase.qtPluginPrefix}";
    };
  };
}
