// quickshell/theme/NetworkStyle.qml
// The `network` section of style.json: the panel card, the hero row, the
// Wi-Fi switch, the stats grid, the band and DNS pills, the network list
// and the password field. Lengths arrive already scaled. The font and
// the scale are the panel's own when it declares them, and the shared
// ones otherwise.
import QtQuick

QtObject {
    id: root

    property var cfg: ({})
    property FontScale sharedFont: null
    property real sharedScale: 1.0

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
        readonly property int width: root.px(root.group("card").width, 380)
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

    readonly property QtObject stats: QtObject {
        readonly property int columnGap: root.px(root.group("stats").columnGap, 20)
        readonly property int rowGap: root.px(root.group("stats").rowGap, 4)
        // fontSize in px wins; otherwise a step of the panel's type scale.
        readonly property int fontSize: root.raw(root.group("stats").fontSize, root.font[root.group("stats").step || "body"])
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

    readonly property QtObject field: QtObject {
        readonly property int paddingX: root.px(root.group("field").paddingX, 8)
        readonly property int paddingY: root.px(root.group("field").paddingY, 6)
        readonly property int radius: root.raw(root.group("field").radius, 4)
        readonly property int border: root.raw(root.group("field").border, 1)
    }
}
