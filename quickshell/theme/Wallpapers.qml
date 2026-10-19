// quickshell/theme/Wallpapers.qml
// The current theme's wallpaper, and moving between its images. Nix lists
// them in wallpapers.json; the image picked for each theme is the shell's
// own state, kept in $XDG_STATE_HOME/sarisarinama/wallpapers.json by file
// name, since a rebuild moves the store paths. A theme shows its picked
// image when it still has it, its default otherwise.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property ConfigFile file: ConfigFile {
        name: "wallpapers"
    }

    readonly property var theme: (root.file.data.themes || {})[Colors.themeName] || {}
    // Every image of the current theme, as store paths, sorted by name.
    readonly property var images: root.theme.all || []
    readonly property string current: root.resolve(root.picked[Colors.themeName])

    // Minutes between moving on; 0 never.
    readonly property int rotate: root.file.value("rotate", 0)

    // Theme name -> file name.
    property var picked: ({})

    function name(path) {
        return path.split("/").pop();
    }

    // A picked file name to its path, if the theme still has it.
    function resolve(fileName) {
        for (var i = 0; i < images.length; i++) {
            if (name(images[i]) === fileName)
                return images[i];
        }
        return root.theme.default || "";
    }

    // "0-winding-road.jpg" -> "Winding Road", as omarchy-theme-bg-current.
    function label(path) {
        return name(path).replace(/\.[^.]+$/, "").replace(/^\d+-/, "").split("-").map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ");
    }

    // Shows an image of the current theme, by file name or path, and keeps
    // it as the theme's pick. false when the theme has no such image.
    function set(fileOrPath) {
        var wanted = name(fileOrPath);
        for (var i = 0; i < images.length; i++) {
            if (name(images[i]) === wanted) {
                var next = Object.assign({}, picked);
                next[Colors.themeName] = wanted;
                picked = next;
                state.setText(JSON.stringify(picked) + "\n");
                return true;
            }
        }
        return false;
    }

    // Moves by `step` through the theme's images, wrapping around.
    function move(step) {
        if (images.length === 0)
            return false;
        var at = images.indexOf(current);
        var to = at < 0 ? 0 : (at + step + images.length) % images.length;
        return set(images[to]);
    }

    FileView {
        id: state
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/sarisarinama/wallpapers.json"
        printErrors: false
        onLoaded: {
            try {
                var parsed = JSON.parse(text());
                root.picked = parsed && typeof parsed === "object" ? parsed : {};
            } catch (e) {
                root.picked = {};
            }
        }
    }

    // A rotation step is a pick like any other, so it is remembered too.
    Timer {
        interval: Math.max(1, root.rotate) * 60000
        running: root.rotate > 0 && root.images.length > 1
        repeat: true
        onTriggered: root.move(1)
    }
}
