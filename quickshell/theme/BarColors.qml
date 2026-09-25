// quickshell/theme/BarColors.qml
// The `bar` block of surfaces.json: the panel and the states its widgets
// paint. Defaults are tokyo-night's, so the bar still shows up when no
// file on disk can be read.
import QtQuick

QtObject {
    id: root

    // Colors.paint bound to the bar section: (key, token, color, alpha).
    property var paint: null

    readonly property color background: root.paint("background", "background", "#1a1b26", 1.0)
    readonly property color text: root.paint("text", "foreground", "#a9b1d6", 1.0)
    readonly property color focused: root.paint("focused", "accent", "#7aa2f7", 1.0)
    readonly property color hover: root.paint("hover", "yellow", "#e0af68", 1.0)
    readonly property color urgent: root.paint("urgent", "red", "#f7768e", 1.0)
}
