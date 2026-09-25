# modules/ui/menu/options.nix
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    entryType = lib.types.submodule {
      options = {
        icon = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Nerd Font glyph shown before the label.";
        };
        label = lib.mkOption {
          type = lib.types.str;
          description = "Text shown in the menu row.";
        };
        action = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Shell command run via bash -lc. Exclusive with `menu`.";
        };
        menu = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Name of another menu to open. Exclusive with `action`.";
        };
      };
    };

    # A menu built at open time instead of at build time: the command runs,
    # and every line of its stdout becomes one row.
    commandType = lib.types.submodule {
      options = {
        command = lib.mkOption {
          type = lib.types.str;
          description = "Shell command; each line of stdout becomes a row.";
        };
        icon = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Glyph shown before every generated label.";
        };
        action = lib.mkOption {
          type = lib.types.str;
          description = ''
            Command run for the chosen row. `{}` is replaced by the line and
            `{shell}` by the running config path, so a row can reach the
            shell over IPC wherever it was launched from.
          '';
        };
      };
    };
  in {
    options.programs.sarisarinama.menus = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either (lib.types.listOf entryType) commandType);
      default = {};
      description = ''
        One menu per attribute: either a list of entries, or a `command`
        that produces them when the menu opens. Each is rendered to
        ~/.config/sarisarinama/<name>.json and opened with the shell's
        `toggle menu '{"file": "<path>"}'` IPC call.
      '';
    };
  };
}
