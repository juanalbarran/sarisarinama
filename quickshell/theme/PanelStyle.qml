// quickshell/theme/PanelStyle.qml
// What every panel's section of style.json shares: the card, the hero row,
// the switch, the pills and the list rows. A panel's own style is this plus
// its own keys (NetworkStyle adds stats and field), so the components in
// panes/common/ read the same names in any panel. Lengths arrive already
// scaled. The font and the scale are the panel's own when it declares them,
// and the shared ones otherwise.
import QtQuick

QtObject {
    id: root

    property var cfg: ({})
    property FontScale sharedFont: null
    property real sharedScale: 1.0
    // The card width when style.json has none; a wider panel sets its own.
    property int defaultWidth: 380

    function group(name) {
        var g = cfg[name];
        return g ? g : {};
    }

    function raw(value, fallback) {
        return value === undefined || value === null ? fallback : value;
    }

    readonly property real scale: root.raw(root.cfg.scale, root.sharedScale)

    readonly property FontScale font: FontScale {
        family: root.raw(root.group("font").family, root.sharedFont ? root.sharedFont.family : "JetBrains Mono Nerd Font")
        size: root.raw(root.group("font").size, root.sharedFont ? root.sharedFont.size : 12)
    }

    function px(value, fallback) {
        return Math.max(1, Math.round(raw(value, fallback) * root.scale));
    }

    // Gap between the sections of the panel.
    readonly property int gap: root.px(root.cfg.gap, 12)

    readonly property QtObject card: QtObject {
        readonly property int width: root.px(root.group("card").width, root.defaultWidth)
        readonly property int padding: root.px(root.group("card").padding, 18)
        // Radius and border are not scaled; they are strokes, not spaces.
        readonly property int radius: root.raw(root.group("card").radius, 8)
        readonly property int border: root.raw(root.group("card").border, 1)
    }

    readonly property QtObject hero: QtObject {
        readonly property int iconSize: root.px(root.group("hero").iconSize, 32)
        readonly property int gap: root.px(root.group("hero").gap, 14)
    }

    readonly property QtObject toggle: QtObject {
        readonly property int width: root.px(root.group("toggle").width, 36)
        readonly property int height: root.px(root.group("toggle").height, 20)
        // A duration, read raw like bar.workspaces.animation.
        readonly property int animation: root.raw(root.group("toggle").animation, 120)
    }

    readonly property QtObject pill: QtObject {
        readonly property int paddingX: root.px(root.group("pill").paddingX, 10)
        readonly property int paddingY: root.px(root.group("pill").paddingY, 4)
        readonly property int gap: root.px(root.group("pill").gap, 6)
        readonly property int radius: root.raw(root.group("pill").radius, 4)
    }

    readonly property QtObject list: QtObject {
        // Past this height the list scrolls instead of growing the panel.
        readonly property int maxHeight: root.px(root.group("list").maxHeight, 260)
        readonly property int spacing: root.px(root.group("list").spacing, 4)
    }

    readonly property QtObject row: QtObject {
        readonly property int paddingX: root.px(root.group("row").paddingX, 10)
        readonly property int paddingY: root.px(root.group("row").paddingY, 6)
        readonly property int gap: root.px(root.group("row").gap, 10)
        readonly property int radius: root.raw(root.group("row").radius, 6)
    }
}
