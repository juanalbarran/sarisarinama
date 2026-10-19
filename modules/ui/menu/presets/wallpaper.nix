# modules/ui/menu/presets/wallpaper.nix
# The wallpaper menu: the current theme's images, each with its picture as
# the row's icon; Enter shows it and keeps it as the theme's pick. Asked of
# the shell when it opens, like the themes menu, so it follows the theme.
# Named `wallpaper`: `wallpapers.json` is already the image list.
{
  flake.modules.homeManager.sarisarinama.programs.sarisarinama.menus.wallpaper = {
    command = "qs -p {shell} ipc call wallpaper entries";
  };
}
