// quickshell/bar/widgets/Workspaces.qml
import Quickshell.I3
import QtQuick
import "../../theme/"

Row {
    spacing: Style.bar.workspaces.spacing

    Repeater {
        model: 5

        Text {
            required property int index
            readonly property var ws: I3.workspaces.values.find(w => w.num === index + 1)

            text: ws?.urgent ? "\uf06a" : ws?.focused ? "\uebb4" : "\u{f0130}"
            font.family: Style.bar.font.family
            font.pixelSize: Style.bar.workspaces.fontSize
            padding: 0
            leftPadding: Style.bar.workspaces.paddingX
            rightPadding: Style.bar.workspaces.paddingX

            color: mouse.containsMouse ? Colors.bar.hover : ws?.urgent ? Colors.bar.urgent : ws?.focused ? Colors.bar.focused : Colors.bar.text

            Behavior on color {
                ColorAnimation {
                    duration: Style.bar.workspaces.animation
                    easing.type: Easing.InOutQuad
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: ws ? ws.activate() : I3.dispatch("workspace number " + (index + 1))
            }
        }
    }
}
