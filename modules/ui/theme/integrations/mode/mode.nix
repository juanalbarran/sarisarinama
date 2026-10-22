# modules/ui/theme/integrations/mode/mode.nix
# Dark theme, dark desktop; light theme, light desktop. The palette's
# `mode` key is written to the GNOME interface settings in dconf on every
# theme set and every Home Manager switch, which GTK and the settings
# portal read, so applications that are not themed key by key still match.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    script = pkgs.writeShellApplication {
      name = "sarisarinama-theme-mode";
      runtimeInputs = [pkgs.jq pkgs.dconf];
      # current-theme.sh sets $state for every integration; this one keeps
      # nothing there.
      excludeShellChecks = ["SC2034"];
      text =
        builtins.readFile ../_lib/current-theme.sh
        + builtins.readFile ./_lib/theme-mode.sh;
    };
  in {
    options.programs.sarisarinama.integrations.mode.enable =
      lib.mkEnableOption "GTK and the settings portal going dark or light with the sarisarinama theme"
      // {default = true;};

    config = lib.mkIf (cfg.enable && cfg.integrations.mode.enable) {
      home.packages = [script];

      programs.sarisarinama.theme.onSet = [(lib.getExe script)];

      # After dconfSettings, so a value Home Manager writes there for the
      # same keys does not undo the theme's on every switch.
      home.activation.sarisarinamaMode = lib.hm.dag.entryAfter ["linkGeneration" "dconfSettings"] ''
        run ${lib.getExe script}
      '';
    };
  };
}
