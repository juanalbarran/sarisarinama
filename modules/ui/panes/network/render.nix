# modules/ui/panes/network/render.nix
# Renders programs.sarisarinama.network to ~/.config/sarisarinama/network.json,
# which the panel reads for its DNS row. Like style.json, the option tree is
# written as it is, so a new network option needs nothing here.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.sarisarinama;
  in {
    config = lib.mkIf cfg.enable {
      xdg.configFile."sarisarinama/network.json".text = builtins.toJSON cfg.network;
    };
  };
}
