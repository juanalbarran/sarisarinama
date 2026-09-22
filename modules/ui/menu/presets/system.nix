# modules/ui/menu/presets/system.nix
# Session and power actions. Has its own options so a host can swap the lock
# command or drop suspend without redefining the whole menu.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.sarisarinama.systemMenu;
  in {
    options.programs.sarisarinama.systemMenu = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Ship the system menu (lock, suspend, restart, power off).";
      };
      lockCommand = lib.mkOption {
        type = lib.types.str;
        default = "loginctl lock-session";
      };
      showSuspend = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };

    config.programs.sarisarinama.menus.system = lib.mkIf cfg.enable (
      [
        {
          icon = "";
          label = "Lock";
          action = cfg.lockCommand;
        }
      ]
      ++ lib.optional cfg.showSuspend {
        icon = "󰒲";
        label = "Suspend";
        action = "systemctl suspend";
      }
      ++ [
        {
          icon = "";
          label = "Restart";
          action = "systemctl reboot";
        }
        {
          icon = "󰐥";
          label = "Power off";
          action = "systemctl poweroff";
        }
      ]
    );
  };
}
