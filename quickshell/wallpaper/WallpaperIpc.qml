// quickshell/wallpaper/WallpaperIpc.qml
// `qs ipc call wallpaper ...`: move between the current theme's images, or
// pick one. `entries` is the wallpaper menu: a JSON array of rows, each
// with the image as its icon and the command that picks it.
import QtQuick
import Quickshell
import Quickshell.Io
import "../theme/"

IpcHandler {
    target: "wallpaper"

    function next(): string {
        return Wallpapers.move(1) ? "ok" : "no wallpapers";
    }

    function previous(): string {
        return Wallpapers.move(-1) ? "ok" : "no wallpapers";
    }

    // A file name of the current theme, as `list` prints them.
    function set(name: string): string {
        return Wallpapers.set(name) ? "ok" : "unknown wallpaper: " + name;
    }

    function get(): string {
        return Wallpapers.name(Wallpapers.current);
    }

    function list(): string {
        return Wallpapers.images.map(Wallpapers.name).join("\n");
    }

    function entries(): string {
        var current = Wallpapers.current;
        return JSON.stringify(Wallpapers.images.map(path => ({
                    image: "file://" + path,
                    label: Wallpapers.label(path) + (path === current ? "  (current)" : ""),
                    action: "qs -p '" + Quickshell.shellDir + "' ipc call wallpaper set '" + Wallpapers.name(path) + "'"
                })));
    }
}
