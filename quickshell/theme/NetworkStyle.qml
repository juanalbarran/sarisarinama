// quickshell/theme/NetworkStyle.qml
// The `network` section of style.json: every panel's keys, from
// PanelStyle, plus the stats grid and the password field.
import QtQuick

PanelStyle {
    id: root

    readonly property QtObject stats: QtObject {
        readonly property int columnGap: root.px(root.group("stats").columnGap, 20)
        readonly property int rowGap: root.px(root.group("stats").rowGap, 4)
        // fontSize in px wins; otherwise a step of the panel's type scale.
        readonly property int fontSize: root.raw(root.group("stats").fontSize, root.font[root.group("stats").step || "body"])
    }

    readonly property QtObject field: QtObject {
        readonly property int paddingX: root.px(root.group("field").paddingX, 8)
        readonly property int paddingY: root.px(root.group("field").paddingY, 6)
        readonly property int radius: root.raw(root.group("field").radius, 4)
        readonly property int border: root.raw(root.group("field").border, 1)
    }
}
