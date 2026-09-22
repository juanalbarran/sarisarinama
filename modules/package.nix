# modules/package.nix
{
  perSystem = {pkgs, ...}: {
    packages.default = pkgs.stdenvNoCC.mkDerivation {
      pname = "sarisarinama";
      version = "0.1.0";
      src = ../quickshell;
      installPhase = ''
        mkdir -p $out/share/sarisarinama
        cp -r . $out/share/sarisarinama/
      '';
    };
  };
}
