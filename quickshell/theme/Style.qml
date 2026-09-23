// quickshell/theme/Style.qml
// Geometry and typography tokens, see docs/style.md. Colors live in
// Colors.qml. `cfg` is style.json as read by StyleFile; every token falls
// back to its default when the section or key is missing.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property StyleFile file: StyleFile {}
    readonly property var cfg: file.data

    function pick(section, key, fallback) {
        var s = cfg[section];
        var v = s ? s[key] : undefined;
        return v === undefined || v === null ? fallback : v;
    }

    // Design pixels scaled by spacing.scale, never below 1.
    function space(px) {
        return Math.max(1, Math.round(px * spacing.scale));
    }

    readonly property QtObject font: QtObject {
        readonly property string family: root.pick("font", "family", "JetBrains Mono Nerd Font")
        readonly property int size: root.pick("font", "size", 12)
        // Type scale, derived; components ask for a step, not a number.
        readonly property int caption: Math.round(size * 0.833)
        readonly property int body: size
        readonly property int title: Math.round(size * 1.167)
        readonly property int heading: Math.round(size * 1.333)
    }

    readonly property QtObject spacing: QtObject {
        readonly property real scale: root.pick("spacing", "scale", 1.0)
    }

    readonly property QtObject card: QtObject {
        readonly property int width: root.pick("card", "width", 300)
        readonly property int padding: root.pick("card", "padding", 18)
        readonly property int radius: root.pick("card", "radius", 8)
        readonly property int border: root.pick("card", "border", 1)
    }

    readonly property QtObject row: QtObject {
        readonly property int height: root.pick("row", "height", 36)
        readonly property int paddingX: root.pick("row", "paddingX", 12)
    }

    // Menu row: the larger of the declared height and text plus padding.
    readonly property int rowHeight: Math.max(space(row.height), font.body + 2 * space(row.paddingX))
}
