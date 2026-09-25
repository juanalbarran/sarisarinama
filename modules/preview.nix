# modules/preview.nix
# Evaluates the whole Home Manager module outside Home Manager, so
# `nix build .#menus` yields exactly the files a rebuild writes: the menus,
# style.json, surfaces.json, theme.json and one file per theme. It sits
# beside home-manager.nix because it belongs to no single component.
# Home Manager's own options are stubbed; Menu.qml expands the leading `~`.
#
# The config block below is the only place this repo sets an option, so it
# is also where to try one out before putting it in the real config.
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
        {
          programs.sarisarinama.enable = true;
          programs.sarisarinama.style.menu.font.size = 16;
        }
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
