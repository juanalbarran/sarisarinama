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
    classify = pkgs.writeShellApplication {
      name = "sarisarinama-projects";
      runtimeInputs = with pkgs; [jq findutils];
      text = builtins.readFile ../_lib/projects.sh;
    };
  in {
    options.programs.sarisarinama.projects.root = lib.mkOption {
      type = lib.types.str;
      default = "~/dev";
      description = "Directory the project menu starts from.";
    };

    config = {
      programs.sarisarinama.menus.projects = {
        command = "sarisarinama-projects {arg}";
        icon = "";
      };
      home.packages = lib.mkIf cfg.enable [classify];
      home.sessionVariables = lib.mkIf cfg.enable {
        SARISARINAMA_PROJECTS_ROOT = cfg.projects.root;
      };
    };
  };
}
