# modules/ui/lock/render.nix
# Renders programs.sarisarinama.lock to ~/.config/sarisarinama/lock.json,
# which the shell reads for the idle timeout. Like network.json, the option
# tree is written as it is, so a new lock option needs nothing here.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.sarisarinama;
  in {
    config = lib.mkIf cfg.enable {
      xdg.configFile."sarisarinama/lock.json".text = builtins.toJSON cfg.lock;
    };
  };
}
