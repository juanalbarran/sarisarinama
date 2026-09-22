# modules/ui/menu/render.nix
# Renders programs.sarisarinama.menus to ~/.config/sarisarinama/<name>.json
# and validates the entries and the references between menus.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    menuDir = "${config.xdg.configHome}/sarisarinama";
    allEntries = lib.concatLists (lib.attrValues cfg.menus);

    # Nulls are dropped so Menu.qml only sees the keys that apply.
    renderEntry = e:
      {inherit (e) icon label;}
      // lib.optionalAttrs (e.action != null) {inherit (e) action;}
      // lib.optionalAttrs (e.menu != null) {menu = "${menuDir}/${e.menu}.json";};

    menuFiles = lib.mapAttrs' (name: entries:
      lib.nameValuePair "sarisarinama/${name}.json" {
        text = builtins.toJSON (map renderEntry entries);
      })
    cfg.menus;

    danglingRefs = lib.unique (
      lib.filter (n: !(cfg.menus ? ${n}))
      (map (e: e.menu) (lib.filter (e: e.menu != null) allEntries))
    );
  in {
    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = lib.all (e: (e.action != null) != (e.menu != null)) allEntries;
          message = "programs.sarisarinama: every entry needs exactly one of `action` or `menu`.";
        }
        {
          assertion = danglingRefs == [];
          message = "programs.sarisarinama: unknown menu referenced: ${lib.concatStringsSep ", " danglingRefs}";
        }
        {
          assertion = cfg.menus ? root;
          message = "programs.sarisarinama: a `root` menu is required; Menu.qml opens it by default.";
        }
      ];

      xdg.configFile = menuFiles;
    };
  };
}
