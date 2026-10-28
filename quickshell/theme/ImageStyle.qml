// quickshell/theme/ImageStyle.qml
// The `image` section of style.json: every panel's keys, from PanelStyle,
// for the caption card, plus the viewer's margin, its zoom and its pan.
import QtQuick

PanelStyle {
    id: root

    // Between the screen's edges, the image and the caption.
    readonly property int margin: root.px(root.cfg.margin, 32)
    // How far one H J K L press moves a zoomed image.
    readonly property int pan: root.px(root.cfg.pan, 80)

    readonly property QtObject zoom: QtObject {
        // Factors, not lengths: read raw.
        readonly property real step: root.raw(root.group("zoom").step, 1.25)
        readonly property real max: root.raw(root.group("zoom").max, 16)
    }

    readonly property QtObject caption: QtObject {
        // Past this a file name is cut in the middle.
        readonly property int maxWidth: root.px(root.group("caption").maxWidth, 900)
    }
}
