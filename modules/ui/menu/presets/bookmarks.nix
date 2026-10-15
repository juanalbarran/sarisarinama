# modules/ui/menu/presets/bookmarks.nix
# Bookmarks: one submenu per category, one row per link. They are plain list
# menus, rendered like any other, so the shell needs nothing new.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.sarisarinama.bookmarks;

    linkType = lib.types.submodule {
      options = {
        label = lib.mkOption {
          type = lib.types.str;
          description = "Text shown in the menu row.";
        };
        url = lib.mkOption {
          type = lib.types.str;
          description = "Address handed to the category's browser.";
        };
      };
    };

    categoryType = lib.types.submodule ({name, ...}: {
      options = {
        label = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Row label in the bookmarks menu; the attribute name by default.";
        };
        icon = lib.mkOption {
          type = lib.types.str;
          default = "󰉋 ";
        };
        browser = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Command that opens a link in this category; null means `bookmarks.browser`.";
        };
        links = lib.mkOption {
          type = lib.types.listOf linkType;
          default = [];
        };
      };
    });

    # One menu file per category, named after it.
    menuName = name: "bookmarks-${name}";

    linkRow = c: l: {
      icon = "󰖟 ";
      inherit (l) label;
      action = "${
        if c.browser != null
        then c.browser
        else cfg.browser
      } ${lib.escapeShellArg l.url}";
    };
  in {
    options.programs.sarisarinama.bookmarks = {
      browser = lib.mkOption {
        type = lib.types.str;
        default = "xdg-open";
        description = "Command that opens a link, the URL appended as one shell word.";
      };
      categories = lib.mkOption {
        type = lib.types.attrsOf categoryType;
        default = {};
        description = "One submenu per attribute, listed in attribute order.";
      };
    };

    config.programs.sarisarinama.menus =
      {
        bookmarks =
          lib.mapAttrsToList (name: c: {
            inherit (c) icon label;
            menu = menuName name;
          })
          cfg.categories;
      }
      // lib.mapAttrs' (name: c: lib.nameValuePair (menuName name) (map (linkRow c) c.links)) cfg.categories;
  };
}
