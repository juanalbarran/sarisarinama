# modules/ui/style/render.nix
# Renders programs.sarisarinama.style to ~/.config/sarisarinama/style.json.
# The option tree already has the shape of the file, so it is serialized
# as is; Style.qml falls back to its defaults for any missing key.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.sarisarinama;
  in {
    config = lib.mkIf cfg.enable {
      xdg.configFile."sarisarinama/style.json".text = builtins.toJSON cfg.style;
    };
  };
}
