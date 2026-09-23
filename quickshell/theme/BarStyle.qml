// quickshell/theme/BarStyle.qml
// The `bar` section of style.json: the bar itself, then the widgets that
// need more than a font size. Widgets share Style.font.family; each names
// a step of the type scale, and `fontSize` overrides that step.
import QtQuick

QtObject {
    id: root

    property var cfg: ({})
    property QtObject fonts: null
    property real scale: 1.0

    function group(name) {
        var g = cfg[name];
        return g ? g : {};
    }

    function px(value, fallback) {
        var v = value === undefined || value === null ? fallback : value;
        return Math.max(1, Math.round(v * scale));
    }

    // Text size of one widget: fontSize wins, else its step of the scale.
    function textSize(widget, fallbackStep) {
        var w = group(widget);
        if (w.fontSize !== undefined && w.fontSize !== null)
            return w.fontSize;
        return fonts[w.step || fallbackStep];
    }

    readonly property int height: px(cfg.height, 30)
    readonly property int paddingLeft: px(cfg.paddingLeft, 40)
    readonly property int paddingRight: px(cfg.paddingRight, 20)
    readonly property int spacing: px(cfg.spacing, 10)

    readonly property QtObject workspaces: QtObject {
        readonly property int fontSize: root.textSize("workspaces", "caption")
        readonly property int spacing: root.px(root.group("workspaces").spacing, 7)
        readonly property int paddingX: root.px(root.group("workspaces").paddingX, 2)
        readonly property int animation: root.group("workspaces").animation ?? 300
    }

    readonly property QtObject tray: QtObject {
        readonly property int iconSize: root.px(root.group("tray").iconSize, 16)
        readonly property int spacing: root.px(root.group("tray").spacing, 8)
    }
}
