// quickshell/theme/BarColors.qml
// The `bar` block of surfaces.json: the panel and the states its widgets
// paint. Defaults are no-clown-fiesta's, so the bar still shows up when no
// file on disk can be read.
import QtQuick

QtObject {
    id: root

    // Colors.paint bound to the bar section: (key, token, color, alpha).
    property var paint: null

    readonly property color background: root.paint("background", "background", "#0d0d0d", 1.0)
    readonly property color text: root.paint("text", "foreground", "#e1e1e1", 1.0)
    readonly property color focused: root.paint("focused", "accent", "#bad7ff", 1.0)
    readonly property color hover: root.paint("hover", "yellow", "#f4bf75", 1.0)
    readonly property color urgent: root.paint("urgent", "red", "#b46958", 1.0)
}
