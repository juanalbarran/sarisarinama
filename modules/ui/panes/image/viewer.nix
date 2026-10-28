# modules/ui/panes/image/viewer.nix
# sarisarinama-image, and the desktop entry that makes it the default for
# images, so xdg-open (and Yazi through it) opens them in the shell's
# viewer instead of the browser. Omarchy does the same with imv.desktop in
# its mimeapps.list.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.sarisarinama;
    open = pkgs.writeShellApplication {
      name = "sarisarinama-image";
      # qs from PATH: the one Home Manager installs, with the image plugins.
      runtimeInputs = [pkgs.jq pkgs.coreutils];
      text = builtins.readFile ./_lib/image-open.sh;
    };
    # What the viewer can decode; WebP and TIFF through qtimageformats.
    mimeTypes = [
      "image/png"
      "image/jpeg"
      "image/gif"
      "image/bmp"
      "image/svg+xml"
      "image/vnd.microsoft.icon"
      "image/webp"
      "image/tiff"
    ];
  in {
    options.programs.sarisarinama.image.enable =
      lib.mkEnableOption "the image viewer as the default application for images"
      // {default = true;};

    config = lib.mkIf (cfg.enable && cfg.image.enable) {
      home.packages = [open];

      xdg.desktopEntries.sarisarinama-image = {
        name = "Image Viewer";
        genericName = "Image Viewer";
        exec = "${lib.getExe open} %f";
        icon = "image-x-generic";
        terminal = false;
        categories = ["Graphics" "Viewer"];
        mimeType = mimeTypes;
      };

      # Written only where xdg.mimeApps.enable is set, as canaima does.
      xdg.mimeApps.defaultApplications =
        lib.genAttrs mimeTypes (_: "sarisarinama-image.desktop");
    };
  };
}
