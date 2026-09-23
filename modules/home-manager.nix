# modules/home-manager.nix
{self, ...}: {
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
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
      home.packages = [pkgs.quickshell cfg.package];
      home.sessionVariables.SARISARINAMA_PATH = "${cfg.package}/share/sarisarinama";
    };
  };
}
