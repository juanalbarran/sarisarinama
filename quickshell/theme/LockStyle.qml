// quickshell/theme/LockStyle.qml
// The `lock` section of style.json: the clock, the gap between the rows
// and the password field. Lengths arrive already scaled. The font and the
// scale are the lock's own when it declares them, the shared ones otherwise.
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

    // Gap between the clock, the date and the field.
    readonly property int gap: root.px(root.cfg.gap, 16)
    // The time is display type, far above the type scale, so it is px.
    readonly property int clockSize: root.px(root.cfg.clockSize, 72)

    readonly property QtObject field: QtObject {
        readonly property int width: root.px(root.group("field").width, 320)
        readonly property int height: root.px(root.group("field").height, 44)
        readonly property int paddingX: root.px(root.group("field").paddingX, 14)
        // Radius and border are not scaled; they are strokes, not spaces.
        readonly property int radius: root.raw(root.group("field").radius, 8)
        readonly property int border: root.raw(root.group("field").border, 2)
    }
}
