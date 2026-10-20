# modules/ui/keybinds/render.nix
# Renders programs.sarisarinama.keybinds to ~/.config/sarisarinama/cheatsheets.json,
# a list of sections in menu order, and builds the `keybinds` menu: one row
# per section, each summoning the pane on it. A section with no binds is
# left out of both. Not keybinds.json: that is the menu.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.sarisarinama;

    sections =
      lib.sort (a: b:
        if a.order != b.order
        then a.order < b.order
        else a.id < b.id)
      (lib.filter (s: lib.any (g: g.binds != []) s.groups)
        (lib.mapAttrsToList (id: s: s // {inherit id;}) cfg.keybinds));

    renderSection = s: {
      inherit (s) id label icon;
      groups = map (g: {inherit (g) title binds;}) (lib.filter (g: g.binds != []) s.groups);
    };

    # The payload is one shell word, so a section name can hold anything.
    summon = id: "qs -p \"$SARISARINAMA_PATH\" ipc call shell summon keybinds ${lib.escapeShellArg (builtins.toJSON {section = id;})}";
  in {
    config = lib.mkIf cfg.enable {
      xdg.configFile."sarisarinama/cheatsheets.json".text = builtins.toJSON (map renderSection sections);

      programs.sarisarinama.menus.keybinds =
        map (s: {
          inherit (s) icon label;
          action = summon s.id;
        })
        sections;
    };
  };
}
