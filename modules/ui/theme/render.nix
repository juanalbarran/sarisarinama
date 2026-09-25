# modules/ui/theme/render.nix
# Renders every palette to ~/.config/sarisarinama/themes/<name>.json, the
# starting theme to theme.json and the surface map to surfaces.json. All
# themes are written, because the shell switches between them at runtime;
# current.json is the shell's own file and is deliberately not managed here.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    resolve = import ./_lib/palette.nix lib;
  in {
    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.theme.palettes ? ${cfg.theme.default};
          message = "programs.sarisarinama.theme.default: no palette named '${cfg.theme.default}'.";
        }
      ];

      xdg.configFile =
        lib.mapAttrs' (name: raw:
          lib.nameValuePair "sarisarinama/themes/${name}.json" {
            text = builtins.toJSON (resolve raw);
          })
        cfg.theme.palettes
        // {
          "sarisarinama/theme.json".text = builtins.toJSON {
            default = cfg.theme.default;
            available = lib.attrNames cfg.theme.palettes;
          };
          "sarisarinama/surfaces.json".text = builtins.toJSON cfg.theme.surfaces;
        };
    };
  };
}
