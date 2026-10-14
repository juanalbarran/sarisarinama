# modules/ui/theme/integrations/palette/palette.nix
# The current theme's palette as one file other programs read and watch:
# ~/.local/state/sarisarinama/palette.json. kukenan (Neovim) paints itself
# from it. Rewritten on every theme set and every Home Manager switch.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    script = pkgs.writeShellApplication {
      name = "sarisarinama-theme-palette";
      runtimeInputs = [pkgs.jq];
      text =
        builtins.readFile ../_lib/current-theme.sh
        + builtins.readFile ./_lib/theme-palette.sh;
    };
  in {
    options.programs.sarisarinama.integrations.palette.enable =
      lib.mkEnableOption "writing the current palette to ~/.local/state/sarisarinama/palette.json"
      // {default = true;};

    config = lib.mkIf (cfg.enable && cfg.integrations.palette.enable) {
      home.packages = [script];

      programs.sarisarinama.theme.onSet = [(lib.getExe script)];

      # Readers find the file from the first login, not from the first
      # theme set, and a changed palette reaches them on a rebuild.
      home.activation.sarisarinamaPalette = lib.hm.dag.entryAfter ["linkGeneration"] ''
        run ${lib.getExe script}
      '';
    };
  };
}
