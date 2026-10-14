# modules/ui/theme/integrations/foot/foot.nix
# foot follows the theme. foot reads its config only at launch, so this is
# two halves: every palette is rendered as a foot colour file and foot's
# config includes one mutable copy, for new windows; on every theme switch
# sarisarinama-theme-foot swaps that copy and repaints the open windows.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    resolve = import ../../_lib/palette.nix lib;
    footIni = import ./_lib/foot-ini.nix lib;
    script = pkgs.writeShellApplication {
      name = "sarisarinama-theme-foot";
      runtimeInputs = [pkgs.jq pkgs.procps];
      text = builtins.readFile ./_lib/theme-foot.sh;
    };
  in {
    options.programs.sarisarinama.integrations.foot.enable =
      lib.mkEnableOption "foot following the sarisarinama theme, open windows included"
      // {
        default = config.programs.foot.enable;
        defaultText = lib.literalExpression "config.programs.foot.enable";
      };

    config = lib.mkIf (cfg.enable && cfg.integrations.foot.enable) {
      home.packages = [script];

      xdg.configFile = lib.mapAttrs' (name: raw:
        lib.nameValuePair "sarisarinama/foot/${name}.ini" {
          text = footIni (resolve raw);
        })
      cfg.theme.palettes;

      # The copy the script writes; the path must match its $state.
      programs.foot.settings.main.include = "${config.xdg.stateHome}/sarisarinama/foot.ini";

      programs.sarisarinama.theme.onSet = [(lib.getExe script)];

      # foot reports a config error when its include is missing, so the
      # copy must exist before the first foot starts. Running on every
      # switch also carries a changed palette to the copy and open windows.
      home.activation.sarisarinamaFoot = lib.hm.dag.entryAfter ["linkGeneration"] ''
        run ${lib.getExe script}
      '';
    };
  };
}
