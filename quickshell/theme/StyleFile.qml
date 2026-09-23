// quickshell/theme/StyleFile.qml
// Reads ~/.config/sarisarinama/style.json into `data`. A missing file or
// bad JSON is logged and yields {} so Style keeps its defaults.
import Quickshell
import Quickshell.Io

FileView {
    id: root

    property var data: ({})

    path: Quickshell.env("HOME") + "/.config/sarisarinama/style.json"
    watchChanges: true
    printErrors: false

    // text() is stale inside fileChanged; reload routes it through onLoaded.
    onFileChanged: root.reload()

    onLoaded: {
        try {
            var parsed = JSON.parse(text());
            root.data = parsed && typeof parsed === "object" ? parsed : {};
        } catch (e) {
            console.warn("style: invalid JSON in", root.path, e);
            root.data = {};
        }
    }

    onLoadFailed: function (error) {
        console.warn("style: cannot read", root.path, "- using defaults", error);
        root.data = {};
    }
}
