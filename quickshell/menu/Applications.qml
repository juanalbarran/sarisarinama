// quickshell/menu/Applications.qml
// The rows of the applications menu: what `wofi --show drun` lists, every
// .desktop file on XDG_DATA_DIRS that is not NoDisplay, sorted by name.
// DesktopEntries scans in the background and adds them one at a time, so
// `entries` is a binding and the list fills in while the menu is open.
import QtQuick
import Quickshell

QtObject {
    id: root

    // Off until a file asks for it, so no other menu builds these rows
    property bool active: false

    readonly property var entries: {
        if (!root.active)
            return [];
        var apps = Array.from(DesktopEntries.applications.values);
        apps.sort((a, b) => a.name.localeCompare(b.name));
        return apps.map(app => ({
                    icon: "󰀻",
                    image: root.iconSource(app.icon),
                    label: app.name,
                    app: app
                }));
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
