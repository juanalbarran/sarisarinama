// quickshell/panes/battery/ChargeBar.qml
// The charge as a bar: a track, and a fill as wide as the charge. Red at
// 15% or less on battery, as the bar's widget; the accent otherwise.
import QtQuick
import "../../theme/"

Rectangle {
    id: root

    required property BatteryState battery

    implicitHeight: Style.battery.charge.height
    radius: height / 2
    color: Colors.battery.track

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        radius: parent.radius
        // Never narrower than it is tall: an empty battery is a dot, not nothing.
        width: Math.max(height, parent.width * root.battery.fraction)
        color: root.battery.low ? Colors.battery.urgent : Colors.battery.accent

        Behavior on width {
            NumberAnimation {
                duration: Style.battery.charge.animation
                easing.type: Easing.OutCubic
            }
        }
    }
}
