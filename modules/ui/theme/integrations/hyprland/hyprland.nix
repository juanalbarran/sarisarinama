# modules/ui/theme/integrations/hyprland/hyprland.nix
# Hyprland's window borders follow the theme. Every palette is rendered as a
# hyprland file, and Hyprland's config sources one mutable copy, last, so its
# colours win over the config's own; sarisarinama-theme-hyprland swaps that
# copy on every theme set. The running Hyprland is repainted by the shell,
# which sources the theme's file itself: see Hypr.qml.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    hypr = config.wayland.windowManager.hyprland;
    resolve = import ../../_lib/palette.nix lib;
    hyprlandConf = import ./_lib/hyprland-conf.nix;
    script = pkgs.writeShellApplication {
      name = "sarisarinama-theme-hyprland";
      runtimeInputs = [pkgs.jq];
      text =
        builtins.readFile ../_lib/current-theme.sh
        + builtins.readFile ./_lib/theme-hyprland.sh;
    };
  in {
    options.programs.sarisarinama.integrations.hyprland.enable =
      lib.mkEnableOption "Hyprland's window borders following the sarisarinama theme"
      // {
        # `source` is hyprlang; a Lua config would need a line of its own.
        default = hypr.enable && (hypr.configType or "hyprlang") == "hyprlang";
        defaultText = lib.literalExpression ''config.wayland.windowManager.hyprland.enable && configType == "hyprlang"'';
      };

    config = lib.mkIf (cfg.enable && cfg.integrations.hyprland.enable) {
      home.packages = [script];

      xdg.configFile = lib.mapAttrs' (name: raw:
        lib.nameValuePair "sarisarinama/hyprland/${name}.conf" {
          text = hyprlandConf (resolve raw);
        })
      cfg.theme.palettes;

      # extraConfig comes after settings, so the theme's colours win. The
      # path must match the script's $state.
      wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
        source = ${config.xdg.stateHome}/sarisarinama/hyprland.conf
      '';

      programs.sarisarinama.theme.onSet = [(lib.getExe script)];

      # The copy exists before Hyprland first reads its config, and a
      # changed palette reaches it on every switch. Before onFilesChange,
      # where Home Manager reloads Hyprland for a changed config: a copy
      # still missing then is a `source=` error until the next reload.
      home.activation.sarisarinamaHyprland = lib.hm.dag.entryBetween ["onFilesChange"] ["linkGeneration"] ''
        run ${lib.getExe script}
      '';
    };
  };
}
