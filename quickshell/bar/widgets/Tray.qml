// quickshell/widgets/Tray.qml
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import "../../theme/"

Row {
    spacing: 8

    Repeater {
        model: SystemTray.items

        IconImage {
            required property var modelData
            implicitSize: 16
            source: modelData.icon
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                onClicked: modelData.activate()
            }
        }
    }
}
