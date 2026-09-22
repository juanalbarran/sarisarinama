# modules/ui/menu/preview.nix
# Renders the menus through the real Home Manager module, outside Home
# Manager, so `nix build .#menus` yields exactly the JSON a rebuild writes.
# Home Manager's own options are stubbed; Menu.qml expands the leading `~`.
{config, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    stubs = {lib, ...}: {
      options = {
        assertions = lib.mkOption {
          type = lib.types.listOf lib.types.attrs;
          default = [];
        };
        home.packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [];
        };
        home.sessionVariables = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = {};
        };
        xdg.configHome = lib.mkOption {
          type = lib.types.str;
          default = "~/.config";
        };
        xdg.configFile = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options.text = lib.mkOption {type = lib.types.str;};
          });
          default = {};
        };
      };
    };

    eval = lib.evalModules {
      specialArgs = {inherit pkgs;};
      modules = [
        config.flake.modules.homeManager.sarisarinama
        stubs
        {programs.sarisarinama.enable = true;}
      ];
    };

    failed = lib.filter (a: !a.assertion) eval.config.assertions;
    files =
      lib.mapAttrsToList (path: f: {
        name = path;
        path = pkgs.writeText (baseNameOf path) f.text;
      })
      eval.config.xdg.configFile;
  in {
    packages.menus =
      if failed != []
      then throw (lib.concatMapStringsSep "\n" (a: a.message) failed)
      else pkgs.linkFarm "sarisarinama-menus" files;
  };
}
