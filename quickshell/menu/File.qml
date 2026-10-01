// quickshell/menu/File.qml
// Reads one menu file and exposes its parsed entries. A missing file or bad
// JSON is logged and yields an empty menu instead of a crash. The file is
// an array of entries, or an object with `command` that produces them.
// `arg` is what the row that opened this menu carried, for a command menu
// that serves many directories from one file.
import Quickshell
import Quickshell.Io

FileView {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string defaultFile: home + "/.config/sarisarinama/root.json"
    property var entries: []
    property string arg: ""

    readonly property Command source: Command {
        onEntriesChanged: root.entries = entries
    }

    // A rebuild that rewrites the file is picked up while the menu is open.
    watchChanges: true
    printErrors: true

    // Accepts "~/..." paths as written by the Nix side; empty means root.
    function load(filePath, argValue) {
        root.arg = argValue || "";
        var target = filePath || root.defaultFile;
        root.path = target.indexOf("~") === 0 ? root.home + target.slice(1) : target;
        root.reload();
    }

    onLoaded: {
        root.entries = [];
        try {
            var parsed = JSON.parse(text());
            if (Array.isArray(parsed))
                root.entries = parsed;
            else if (parsed && parsed.command)
                root.source.run(parsed, root.arg);
            else
                console.warn("menu: neither entries nor a command in", root.path);
        } catch (e) {
            console.warn("menu: invalid JSON in", root.path, e);
        }
    }

    onLoadFailed: function (error) {
        console.warn("menu: cannot read", root.path, error);
        root.entries = [];
    }
}
