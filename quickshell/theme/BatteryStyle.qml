// quickshell/theme/BatteryStyle.qml
// The `battery` section of style.json: every panel's keys, from
// PanelStyle, plus the charge bar.
import QtQuick

PanelStyle {
    id: root

    readonly property QtObject charge: QtObject {
        readonly property int height: root.px(root.group("charge").height, 8)
        // A duration, read raw like toggle.animation.
        readonly property int animation: root.raw(root.group("charge").animation, 320)
    }
}
