# modules/ui/panes/monitor/lid.nix
# sarisarinama-lid, and the lid binds that run it on Sway and Hyprland:
# closing the lid with an external screen turns the laptop panel off,
# opening it turns the panel back on.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    lid = pkgs.writeShellApplication {
      name = "sarisarinama-lid";
      runtimeInputs = [pkgs.jq];
      text = builtins.readFile ./_lib/lid.sh;
    };
    run = state: "${lib.getExe lid} ${state}";
  in {
    options.programs.sarisarinama.monitor.lid.enable =
      lib.mkEnableOption "turning the laptop panel off while the lid is shut and an external screen is on"
      // {default = true;};

    config = lib.mkIf (cfg.enable && cfg.monitor.lid.enable) {
      home.packages = [lid];

      # --reload also runs the bind for the current lid state when the
      # config loads, so booting with the lid shut is handled too.
      wayland.windowManager.sway.config.bindswitches = {
        "lid:on" = {
          reload = true;
          locked = true;
          action = "exec ${run "closed"}";
        };
        "lid:off" = {
          reload = true;
          locked = true;
          action = "exec ${run "open"}";
        };
      };

      # Untested: Hyprland is not ported yet. "Lid Switch" is the libinput
      # device name; check yours with `hyprctl devices`.
      wayland.windowManager.hyprland.settings.bindl = [
        ", switch:on:Lid Switch, exec, ${run "closed"}"
        ", switch:off:Lid Switch, exec, ${run "open"}"
      ];
    };
  };
}
