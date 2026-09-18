// quickshell/Workspaces.qml
import Quickshell.I3
import QtQuick

Row {
    spacing: 7

    Repeater {
        model: 5

        Text {
            required property int index
            readonly property var ws: I3.workspaces.values.find(w => w.num === index + 1)

            text: ws?.urgent ? "\uf06a" : ws?.focused ? "\uebb4" : "\u{f0130}"
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 10
            padding: 0
            leftPadding: 2
            rightPadding: 2

            color: mouse.containsMouse ? Colors.hover : ws?.urgent ? Colors.urgent : ws?.focused ? Colors.accent : Colors.text

            Behavior on color {
                ColorAnimation {
                    duration: 300
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
