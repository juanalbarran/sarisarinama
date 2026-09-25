// quickshell/theme/Colors.qml
// Colors, and only colors; geometry is Style.qml. surfaces.json says which
// palette key paints what, themes/<name>.json is the palette, and the theme
// in use is current.json falling back to theme.json. Every token has a
// default here, so the shell paints itself when no file can be read.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property ConfigFile themeFile: ConfigFile {
        name: "theme"
    }

    // The shell's own file, written over IPC; absent until a theme is set.
    readonly property ConfigFile currentFile: ConfigFile {
        name: "current"
    }

    readonly property ConfigFile surfaceFile: ConfigFile {
        name: "surfaces"
    }

    // Set by ThemeIpc; "" means "whatever the files say". Held in memory so
    // a switch is instant: current.json is persistence, not the source.
    property string selected: ""

    readonly property string themeName: root.selected !== "" ? root.selected : root.currentFile.value("default", root.themeFile.value("default", "tokyo-night"))

    readonly property ConfigFile paletteFile: ConfigFile {
        name: "themes/" + root.themeName
    }

    // A surface value names a palette key, or is a literal "#rrggbb".
    function lookup(token, fallback) {
        if (typeof token !== "string" || token === "")
            return fallback;
        if (token.charAt(0) === "#")
            return token;
        var v = root.paletteFile.data[token];
        return typeof v === "string" ? v : fallback;
    }

    function token(section, key, fallback) {
        var s = root.surfaceFile.data[section];
        var v = s ? s[key] : undefined;
        return v === undefined || v === null ? fallback : v;
    }

    // One surface: its key resolved through the palette, its alpha applied.
    function paint(section, key, defToken, defColor, defAlpha) {
        var hex = root.lookup(root.token(section, key, defToken), defColor);
        return Qt.alpha(hex, root.token(section, key + "Alpha", defAlpha));
    }

    readonly property BarColors bar: BarColors {
        paint: (key, token, color, alpha) => root.paint("bar", key, token, color, alpha)
    }

    readonly property MenuColors menu: MenuColors {
        paint: (key, token, color, alpha) => root.paint("menu", key, token, color, alpha)
    }
}
