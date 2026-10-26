// quickshell/menu/Applications.qml
// The rows of the applications menu: what `wofi --show drun` lists, every
// .desktop file on XDG_DATA_DIRS that is not NoDisplay, sorted by name.
// DesktopEntries scans in the background and adds them one at a time. The
// scan starts with the shell, and the rows are built once it settles, not
// once per entry: rebuilding every row for every entry was what made the
// first open slow. An app installed later rebuilds them once more.
import QtQuick
import Quickshell

QtObject {
    id: root

    // On while a file shows these rows; they are built either way
    property bool active: false
    // The rows were built at least once: until then the menu waits
    property bool ready: false
    property var entries: []

    // Reading the list starts the scan; every change restarts the wait
    readonly property Connections watch: Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            root.settle.restart();
        }
    }

    readonly property Timer settle: Timer {
        interval: 100
        running: true
        onTriggered: root.build()
    }

    function build() {
        var apps = Array.from(DesktopEntries.applications.values);
        apps.sort((a, b) => a.name.localeCompare(b.name));
        root.entries = apps.map(app => ({
                    icon: "󰀻",
                    image: root.iconSource(app.icon),
                    label: app.name,
                    app: app
                }));
        root.ready = true;
    }

    // A theme icon name or an absolute path; "" when the theme has neither,
    // and the row falls back to the glyph
    function iconSource(name) {
        if (!name)
            return "";
        if (name.indexOf("/") === 0)
            return "file://" + name;
        return Quickshell.iconPath(name, true);
    }
}
