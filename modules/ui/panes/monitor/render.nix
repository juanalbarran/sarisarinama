# modules/ui/panes/monitor/render.nix
# Renders programs.sarisarinama.monitor to ~/.config/sarisarinama/monitor.json,
# which the panel reads for its scale row. Like network.json, the option
# tree is written as it is, so a new monitor option needs nothing here.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.sarisarinama;
  in {
    config = lib.mkIf cfg.enable {
      xdg.configFile."sarisarinama/monitor.json".text = builtins.toJSON cfg.monitor;
    };
  };
}
