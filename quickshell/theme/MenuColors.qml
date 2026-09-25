// quickshell/theme/MenuColors.qml
// The `menu` block of surfaces.json: the card, its title and its rows.
// Defaults are tokyo-night's, so the menu still paints without a file.
import QtQuick

QtObject {
    id: root

    // Colors.paint bound to the menu section: (key, token, color, alpha).
    property var paint: null

    readonly property color background: root.paint("background", "background", "#1a1b26", 1.0)
    readonly property color text: root.paint("text", "foreground", "#a9b1d6", 1.0)
    readonly property color title: root.paint("title", "accent", "#7aa2f7", 1.0)
    readonly property color border: root.paint("border", "accent", "#7aa2f7", 1.0)
    readonly property color selectedBackground: root.paint("selectedBackground", "foreground", "#a9b1d6", 0.08)
    readonly property color selectedText: root.paint("selectedText", "accent", "#7aa2f7", 1.0)
}
