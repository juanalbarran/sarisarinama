// quickshell/theme/KeybindsStyle.qml
// The `keybinds` section of style.json: every panel's keys, from
// PanelStyle, with a wider card, plus the columns and the keycaps.
import QtQuick

PanelStyle {
    id: root

    defaultWidth: 820

    // Largest share of the screen's height before the binds scroll.
    readonly property real maxHeight: root.raw(root.cfg.maxHeight, 0.75)

    readonly property QtObject columns: QtObject {
        readonly property int count: root.raw(root.group("columns").count, 1)
        readonly property int gap: root.px(root.group("columns").gap, 28)
        readonly property int groupGap: root.px(root.group("columns").groupGap, 18)
        // Share of a column the keys take; the description gets the rest.
        readonly property real keysWidth: root.raw(root.group("columns").keysWidth, 0.38)
    }

    readonly property QtObject keycap: QtObject {
        readonly property int paddingX: root.px(root.group("keycap").paddingX, 6)
        readonly property int paddingY: root.px(root.group("keycap").paddingY, 2)
        readonly property int radius: root.raw(root.group("keycap").radius, 4)
        readonly property int depth: root.raw(root.group("keycap").depth, 2)
        readonly property int gap: root.px(root.group("keycap").gap, 4)
        readonly property int stepGap: root.px(root.group("keycap").stepGap, 10)
    }
}
