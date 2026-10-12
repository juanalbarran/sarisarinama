// quickshell/theme/PanelColors.qml
// What every panel's block of surfaces.json shares: the card, its text, the
// switch, the pills and the list rows. A panel's own colors are this plus
// its own keys (NetworkColors adds the password field). Defaults are
// no-clown-fiesta's, so a panel still paints without a file.
import QtQuick

QtObject {
    id: root

    // Colors.paint bound to the panel's section: (key, token, color, alpha).
    property var paint: null

    readonly property color background: root.paint("background", "background", "#0d0d0d", 1.0)
    readonly property color border: root.paint("border", "accent", "#bad7ff", 1.0)
    readonly property color text: root.paint("text", "foreground", "#e1e1e1", 1.0)
    readonly property color muted: root.paint("muted", "dark_foreground", "#727272", 1.0)
    readonly property color accent: root.paint("accent", "accent", "#bad7ff", 1.0)
    readonly property color track: root.paint("track", "muted", "#373737", 1.0)
    readonly property color urgent: root.paint("urgent", "red", "#b46958", 1.0)
    readonly property color separator: root.paint("separator", "muted", "#373737", 1.0)
    readonly property color hover: root.paint("hover", "foreground", "#e1e1e1", 0.08)
    readonly property color current: root.paint("current", "accent", "#bad7ff", 0.10)
    readonly property color cursor: root.paint("cursor", "accent", "#bad7ff", 1.0)
}
