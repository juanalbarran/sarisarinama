// quickshell/theme/MenuStyle.qml
// The `menu` section of style.json: the card and its rows. Lengths arrive
// already scaled, so Card.qml and Entry.qml never call Style.space. The
// font and the scale are the menu's own when it declares them, and the
// shared ones otherwise.
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

    readonly property QtObject card: QtObject {
        readonly property int width: root.px(root.group("card").width, 300)
        readonly property int padding: root.px(root.group("card").padding, 18)
        // Radius and border are not scaled; they are strokes, not spaces.
        readonly property int radius: root.raw(root.group("card").radius, 8)
        readonly property int border: root.raw(root.group("card").border, 1)
    }

    readonly property QtObject row: QtObject {
        readonly property int height: root.px(root.group("row").height, 36)
        readonly property int paddingX: root.px(root.group("row").paddingX, 12)
    }

    // A row is the larger of the declared height and text plus padding.
    readonly property int rowHeight: Math.max(root.row.height, root.font.body + 2 * root.row.paddingX)
}
