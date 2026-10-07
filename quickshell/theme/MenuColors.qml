// quickshell/theme/MenuColors.qml
// The `menu` block of surfaces.json: the card, its title and its rows.
// Defaults are no-clown-fiesta's, so the menu still paints without a file.
import QtQuick

QtObject {
    id: root

    // Colors.paint bound to the menu section: (key, token, color, alpha).
    property var paint: null

    readonly property color background: root.paint("background", "background", "#0d0d0d", 1.0)
    readonly property color text: root.paint("text", "foreground", "#e1e1e1", 1.0)
    readonly property color title: root.paint("title", "accent", "#bad7ff", 1.0)
    readonly property color border: root.paint("border", "accent", "#bad7ff", 1.0)
    readonly property color selectedBackground: root.paint("selectedBackground", "foreground", "#e1e1e1", 0.08)
    readonly property color selectedText: root.paint("selectedText", "accent", "#bad7ff", 1.0)
    readonly property color placeholder: root.paint("placeholder", "muted", "#373737", 1.0)
}
