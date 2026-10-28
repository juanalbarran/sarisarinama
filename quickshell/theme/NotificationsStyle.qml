// quickshell/theme/NotificationsStyle.qml
// The `notifications` section of style.json: every panel's keys, from
// PanelStyle, for the history panel, plus the toasts, the history list and
// the message beside it.
import QtQuick

PanelStyle {
    id: root

    defaultWidth: 420

    readonly property QtObject toast: QtObject {
        readonly property int width: root.px(root.group("toast").width, 380)
        readonly property int padding: root.px(root.group("toast").padding, 12)
        // Between one toast and the next.
        readonly property int gap: root.px(root.group("toast").gap, 8)
        // From the screen's top and right edges.
        readonly property int margin: root.px(root.group("toast").margin, 12)
        readonly property int iconSize: root.px(root.group("toast").iconSize, 40)
        // Radius and border are not scaled; they are strokes, not spaces.
        readonly property int radius: root.raw(root.group("toast").radius, 8)
        readonly property int border: root.raw(root.group("toast").border, 2)
        // Counts, read raw.
        readonly property int bodyLines: root.raw(root.group("toast").bodyLines, 3)
        readonly property int max: root.raw(root.group("toast").max, 5)
    }

    readonly property QtObject history: QtObject {
        // Past this height the history scrolls instead of growing the panel.
        readonly property int maxHeight: root.px(root.group("history").maxHeight, 420)
        readonly property int iconSize: root.px(root.group("history").iconSize, 28)
    }

    // The notification shown in full, the panel's right column.
    readonly property QtObject message: QtObject {
        readonly property int width: root.px(root.group("message").width, 480)
    }
}
