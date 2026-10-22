# modules/ui/theme/integrations/tmux/tmux.nix
# tmux follows the theme. The same two halves as foot: every palette is
# rendered as a tmux file and tmux's config sources one mutable copy, for
# servers started later; on every theme switch sarisarinama-theme-tmux swaps
# that copy and sources it into the running server.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    resolve = import ../../_lib/palette.nix lib;
    tmuxConf = import ./_lib/tmux-conf.nix lib;
    script = pkgs.writeShellApplication {
      name = "sarisarinama-theme-tmux";
      # The client must match the server it talks to: the configured tmux.
      runtimeInputs = [pkgs.jq config.programs.tmux.package];
      text =
        builtins.readFile ../_lib/current-theme.sh
        + builtins.readFile ./_lib/theme-tmux.sh;
    };
  in {
    options.programs.sarisarinama.integrations.tmux = {
      enable =
        lib.mkEnableOption "tmux following the sarisarinama theme, running sessions included"
        // {
          default = config.programs.tmux.enable;
          defaultText = lib.literalExpression "config.programs.tmux.enable";
        };

      roles = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            subtle = lib.mkOption {
              type = lib.types.str;
              default = "muted";
              description = "Paints the other windows' names and the pane borders.";
            };
            highlight = lib.mkOption {
              type = lib.types.str;
              default = "accent";
              description = "Paints the current window, the active border and messages.";
            };
          };
        });
        default = {};
        example = lib.literalExpression ''{ no-clown-fiesta.subtle = "dark_foreground"; }'';
        description = ''
          Per theme, which palette key, or literal #rrggbb, paints tmux's
          bar and borders. A theme whose `muted` is too dark to read there
          names another key.
        '';
      };
    };

    config = lib.mkIf (cfg.enable && cfg.integrations.tmux.enable) {
      home.packages = [script];

      # Every theme has roles, the defaults unless it set its own.
      programs.sarisarinama.integrations.tmux.roles = lib.mapAttrs (_: _: {}) cfg.theme.palettes;

      xdg.configFile = lib.mapAttrs' (name: raw:
        lib.nameValuePair "sarisarinama/tmux/${name}.conf" {
          text = tmuxConf cfg.integrations.tmux.roles.${name} (resolve raw);
        })
      cfg.theme.palettes;

      # Last, so the theme's colours win over any set earlier in the config.
      # The path must match the script's $state; -q because a missing copy
      # only means no colours yet.
      programs.tmux.extraConfig = lib.mkAfter ''
        source-file -q ${config.xdg.stateHome}/sarisarinama/tmux.conf
      '';

      programs.sarisarinama.theme.onSet = [(lib.getExe script)];

      # The copy exists before the first tmux starts, and a changed palette
      # reaches the copy and the running server on every switch.
      home.activation.sarisarinamaTmux = lib.hm.dag.entryAfter ["linkGeneration"] ''
        run ${lib.getExe script}
      '';
    };
  };
}
