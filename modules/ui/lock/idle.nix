# modules/ui/lock/idle.nix
# programs.sarisarinama.lock.idle: how long without input before the shell
# locks. Read by the shell from lock.json, see render.nix.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: {
    options.programs.sarisarinama.lock.idle = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 300;
      example = 600;
      description = ''
        Seconds without keyboard or pointer input before the screen locks;
        0 never locks on idle. An app that inhibits idle, such as a video
        player in full screen, holds it off.
      '';
    };
  };
}
