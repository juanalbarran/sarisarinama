# modules/ui/menu/presets/projects.nix
# The project menu: one directory per open, classified by _lib/projects.sh.
# A subdirectory with a marker is a project and its row launches it; anything
# else is a branch and its row reopens this menu one level down. The menu is
# the same file at every level; `{arg}` is what changes.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    isProject = builtins.readFile ../_lib/is-project.sh;
    classify = pkgs.writeShellApplication {
      name = "sarisarinama-projects";
      runtimeInputs = with pkgs; [jq findutils];
      text = isProject + builtins.readFile ../_lib/projects.sh;
    };
    open = pkgs.writeShellApplication {
      name = "sarisarinama-open-project";
      runtimeInputs = with pkgs; [jq libnotify procps];
      runtimeEnv.SARISARINAMA_TERMINAL = cfg.projects.terminal;
      text = builtins.readFile ../_lib/open-project.sh;
    };
    entry = pkgs.writeShellApplication {
      name = "sarisarinama-projects-menu";
      runtimeInputs = [pkgs.jq open];
      text = isProject + builtins.readFile ../_lib/projects-menu.sh;
    };
  in {
    options.programs.sarisarinama.projects.root = lib.mkOption {
      type = lib.types.str;
      default = "~/dev";
      description = "Directory the project menu starts from.";
    };
    options.programs.sarisarinama.projects.terminal = lib.mkOption {
      type = lib.types.str;
      default = "foot";
      example = "ghostty -e";
      description = ''
        Terminal a project opens in, from PATH, with the flags it needs
        before the command it runs: `foot` takes the command as is,
        `ghostty -e` and `alacritty -e` need the `-e`.
      '';
    };

    config = {
      programs.sarisarinama.menus.projects = {
        command = "sarisarinama-projects {arg}";
        icon = "";
        backWithin = true;
      };
      home.packages = lib.mkIf cfg.enable [classify open entry];
      home.sessionVariables = lib.mkIf cfg.enable {
        SARISARINAMA_PROJECTS_ROOT = cfg.projects.root;
      };
    };
  };
}
