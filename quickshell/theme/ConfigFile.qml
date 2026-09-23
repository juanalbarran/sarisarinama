// quickshell/theme/ConfigFile.qml
// Reads ~/.config/sarisarinama/<name>.json into `data`. A missing file or
// bad JSON is logged and yields {}, so every caller keeps its defaults.
import Quickshell
import Quickshell.Io

FileView {
    id: root

    property string name: "style"
    property var data: ({})

    // Flat lookup with a fallback; Style adds its own section lookup.
    function value(key, fallback) {
        var v = data[key];
        return v === undefined || v === null ? fallback : v;
    }

    path: Quickshell.env("HOME") + "/.config/sarisarinama/" + name + ".json"
    watchChanges: true
    printErrors: false

    // text() is stale inside fileChanged; reload routes it through onLoaded.
    onFileChanged: root.reload()

    onLoaded: {
        try {
            var parsed = JSON.parse(text());
            root.data = parsed && typeof parsed === "object" ? parsed : {};
        } catch (e) {
            console.warn("config: invalid JSON in", root.path, e);
            root.data = {};
        }
    }

    onLoadFailed: function (error) {
        console.warn("config: cannot read", root.path, "- using defaults", error);
        root.data = {};
    }
}
