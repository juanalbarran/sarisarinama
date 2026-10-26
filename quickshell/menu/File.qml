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
    // A command menu's `backWithin`: Back only returns to this same file
    property bool backWithin: false
    // From load() until the rows of the file it loads are in: the menu
    // waits on it, so it never opens empty and then grows
    property bool loading: false

    readonly property Command source: Command {
        onEntriesChanged: root.entries = entries
        onFinished: root.loading = false
    }

    readonly property Applications apps: Applications {
        onEntriesChanged: if (active)
            root.entries = entries
    }

    // A rebuild that rewrites the file is picked up while the menu is open.
    watchChanges: true
    printErrors: true

    // Accepts "~/..." paths as written by the Nix side; empty means root.
    function load(filePath, argValue) {
        root.arg = argValue || "";
        root.loading = true;
        var target = filePath || root.defaultFile;
        root.path = target.indexOf("~") === 0 ? root.home + target.slice(1) : target;
        root.reload();
    }

    function show(rows) {
        root.entries = rows;
        root.loading = false;
    }

    // A command menu keeps the rows shown until its own arrive
    onLoaded: {
        root.backWithin = false;
        root.apps.active = false;
        try {
            var parsed = JSON.parse(text());
            root.backWithin = !Array.isArray(parsed) && !!(parsed && parsed.backWithin);
            if (Array.isArray(parsed))
                root.show(parsed);
            else if (parsed && parsed.command)
                root.source.run(parsed, root.arg);
            else if (parsed && parsed.source === "applications") {
                root.apps.active = true;
                root.show(root.apps.entries);
            } else {
                console.warn("menu: neither entries nor a command in", root.path);
                root.show([]);
            }
        } catch (e) {
            console.warn("menu: invalid JSON in", root.path, e);
            root.show([]);
        }
    }

    onLoadFailed: function (error) {
        console.warn("menu: cannot read", root.path, error);
        root.apps.active = false;
        root.show([]);
    }
}
