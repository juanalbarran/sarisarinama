# modules/ui/notifications/options.nix
# programs.sarisarinama.notifications: whether the shell is the notification
# daemon. Read by the shell from notifications.json, see render.nix.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: {
    options.programs.sarisarinama.notifications.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Make the shell the notification daemon: it claims
        org.freedesktop.Notifications on the session bus, draws toasts in the
        top-right corner and keeps a history behind the bar's bell. Only one
        daemon can own the bus name, so stop any other (dunst, mako, swaync)
        first; while one holds it, the shell receives nothing.
      '';
    };
  };
}
