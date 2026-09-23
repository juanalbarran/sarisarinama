// quickshell/theme/Style.qml
// What every component shares, plus one object per component, see
// docs/style.md. Colors live in Colors.qml; style never holds a color.
// Every token falls back to its default when style.json lacks the key.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property ConfigFile file: ConfigFile {}
    readonly property var cfg: file.data

    // One section of style.json, or {} while the file is missing.
    function section(name) {
        var s = cfg[name];
        return s ? s : {};
    }

    function pick(name, key, fallback) {
        var v = section(name)[key];
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

    readonly property BarStyle bar: BarStyle {
        cfg: root.section("bar")
        fonts: root.font
        scale: root.spacing.scale
    }

    readonly property MenuStyle menu: MenuStyle {
        cfg: root.section("menu")
        body: root.font.body
        scale: root.spacing.scale
    }
}
