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
        fonts.fontconfig.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
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
        wayland.windowManager.sway.config.bindswitches = lib.mkOption {
          type = lib.types.attrsOf lib.types.attrs;
          default = {};
        };
        wayland.windowManager.hyprland.settings = lib.mkOption {
          type = lib.types.attrs;
          default = {};
        };
        programs.foot.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        programs.foot.settings = lib.mkOption {
          type = lib.types.attrs;
          default = {};
        };
        home.activation = lib.mkOption {
          type = lib.types.attrs;
          default = {};
        };
        targets.genericLinux.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        xdg.stateHome = lib.mkOption {
          type = lib.types.str;
          default = "~/.local/state";
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
          programs.foot.enable = true;
          programs.sarisarinama.bookmarks.categories = {
            code.links = [
              {
                label = "Github";
                url = "https://github.com/juanalbarran";
              }
              {
                label = "Tony, btw";
                url = "https://tonybtw.com";
              }
            ];
            work = {
              label = "Work";
              browser = "brave";
              links = [
                {
                  label = "ctwo";
                  url = "https://ctwo.com";
                }
              ];
            };
          };
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
