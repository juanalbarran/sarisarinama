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
  in {
    options.programs.sarisarinama.menus = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf entryType);
      default = {};
      description = ''
        One list of entries per menu; the attribute name is the menu name.
        Each menu is rendered to ~/.config/sarisarinama/<name>.json and
        opened with the shell's `toggle menu '{"file": "<path>"}'` IPC call.
      '';
    };
  };
}
