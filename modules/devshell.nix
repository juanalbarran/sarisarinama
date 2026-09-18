# ./modules/devshell.nix
{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        quickshell
        qt6.qtdeclarative
      ];
    };
  };
}
