// quickshell/theme/LockColors.qml
// The `lock` block of surfaces.json: the screen behind everything, its
// text and the password field, from omarchy's [lock]. Defaults are
// no-clown-fiesta's, so the lock still paints without a file.
import QtQuick

QtObject {
    id: root

    // Colors.paint bound to the lock's section: (key, token, color, alpha).
    property var paint: null

    readonly property color background: root.paint("background", "background", "#0d0d0d", 1.0)
    readonly property color text: root.paint("text", "foreground", "#e1e1e1", 1.0)
    readonly property color muted: root.paint("muted", "dark_foreground", "#727272", 1.0)
    readonly property color field: root.paint("field", "lighter_background", "#1a1a1a", 1.0)
    readonly property color fieldBorder: root.paint("fieldBorder", "accent", "#bad7ff", 1.0)
    readonly property color urgent: root.paint("urgent", "red", "#b46958", 1.0)
}
