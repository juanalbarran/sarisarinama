# modules/ui/menu/presets/sessions.nix
# The sessions menu: the running tmux sessions, asked of tmux when the menu
# opens, the one attached last first. A row shows its session, run or raise,
# as the project menu does. Not in the root menu: a config binds it to a key.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    list = pkgs.writeShellApplication {
      name = "sarisarinama-sessions";
      runtimeInputs = with pkgs; [jq coreutils];
      text = builtins.readFile ../_lib/sessions.sh;
    };
    open = pkgs.writeShellApplication {
      name = "sarisarinama-open-session";
      runtimeInputs = with pkgs; [jq libnotify procps coreutils];
      runtimeEnv.SARISARINAMA_TERMINAL = cfg.projects.terminal;
      text = builtins.readFile ../_lib/raise-session.sh + builtins.readFile ../_lib/open-session.sh;
    };
  in {
    config = {
      programs.sarisarinama.menus.sessions.command = "sarisarinama-sessions";
      home.packages = lib.mkIf cfg.enable [list open];
    };
  };
}
