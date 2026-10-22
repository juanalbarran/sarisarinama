# modules/ui/theme/integrations/qutebrowser/qutebrowser.nix
# qutebrowser's dark pages follow the theme: dark with a dark theme, light
# with a light one, the setting its ,d key cycles. No script: qutebrowser
# reads palette.json itself, at start and whenever it changes, as kukenan
# does, so the palette integration must be on. Sending qutebrowser a
# command from outside would raise its window on every switch instead.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.sarisarinama;
  in {
    options.programs.sarisarinama.integrations.qutebrowser.enable =
      lib.mkEnableOption "qutebrowser's dark pages following the sarisarinama theme, open windows included"
      // {
        default = config.programs.qutebrowser.enable && cfg.integrations.palette.enable;
        defaultText = lib.literalExpression "config.programs.qutebrowser.enable && config.programs.sarisarinama.integrations.palette.enable";
      };

    config = lib.mkIf (cfg.enable && cfg.integrations.qutebrowser.enable) {
      assertions = [
        {
          assertion = cfg.integrations.palette.enable;
          message = "programs.sarisarinama.integrations.qutebrowser reads palette.json: enable integrations.palette too.";
        }
      ];

      # The directory palette.json is written to, as the palette script's $state.
      programs.qutebrowser.extraConfig =
        builtins.replaceStrings ["@state@"] ["${config.xdg.stateHome}/sarisarinama"]
        (builtins.readFile ./_lib/darkmode.py);
    };
  };
}
