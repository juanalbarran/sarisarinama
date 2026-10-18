// quickshell/theme/AudioStyle.qml
// The `audio` section of style.json: every panel's keys, from
// PanelStyle, plus the volume slider.
import QtQuick

PanelStyle {
    id: root

    readonly property QtObject slider: QtObject {
        readonly property int height: root.px(root.group("slider").height, 4)
        readonly property int knob: root.px(root.group("slider").knob, 12)
    }
}
