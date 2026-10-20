# modules/ui/keybinds/options.nix
# programs.sarisarinama.keybinds: the cheat sheets the keybinds pane shows,
# one section per application. A section is groups of binds, each a key
# combination and what it does. Written in Nix, so a config can build a
# section from its own data (canaima builds the compositor's from ui.*).
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: let
    bindType = lib.types.submodule {
      options = {
        keys = lib.mkOption {
          type = lib.types.str;
          example = "Ctrl+b c";
          description = ''
            What to press. `+` joins the keys of one chord, a space separates
            chords pressed one after the other: `Ctrl+b c` is Ctrl+b, then c.
            Each key is drawn as a keycap; write the key `+` as `Plus` and
            the key space as `Space`.
          '';
        };
        description = lib.mkOption {
          type = lib.types.str;
          description = "What the bind does.";
        };
      };
    };

    groupType = lib.types.submodule {
      options = {
        title = lib.mkOption {
          type = lib.types.str;
          description = "Heading over the group's binds.";
        };
        binds = lib.mkOption {
          type = lib.types.listOf bindType;
          default = [];
        };
      };
    };

    sectionType = lib.types.submodule ({name, ...}: {
      options = {
        label = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Name in the keybinds menu and the pane's title; the attribute name by default.";
        };
        icon = lib.mkOption {
          type = lib.types.str;
          default = "󰌌 ";
          description = "Nerd Font glyph in the menu row and the pane's title.";
        };
        order = lib.mkOption {
          type = lib.types.int;
          default = 50;
          description = "Lower comes first in the menu and the pane's tabs; ties go by name.";
        };
        groups = lib.mkOption {
          type = lib.types.listOf groupType;
          default = [];
          description = ''
            The groups, in order. Definitions are concatenated, so a config
            adds a group to a preset with `lib.mkAfter [...]` and replaces
            the preset's with `lib.mkForce [...]`.
          '';
        };
      };
    });
  in {
    options.programs.sarisarinama.keybinds = lib.mkOption {
      type = lib.types.attrsOf sectionType;
      default = {};
      description = ''
        One section per attribute. All are rendered to
        ~/.config/sarisarinama/cheatsheets.json, and each becomes a row of the
        `keybinds` menu that opens the pane on it.
      '';
    };
  };
}
