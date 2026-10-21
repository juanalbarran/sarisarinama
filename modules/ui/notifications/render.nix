# modules/ui/notifications/render.nix
# Renders programs.sarisarinama.notifications to
# ~/.config/sarisarinama/notifications.json, which the shell reads to know
# whether to claim the bus. Like lock.json, the option tree is written as it
# is, so a new notifications option needs nothing here.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.sarisarinama;
  in {
    config = lib.mkIf cfg.enable {
      xdg.configFile."sarisarinama/notifications.json".text = builtins.toJSON cfg.notifications;
    };
  };
}
