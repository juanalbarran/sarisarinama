// quickshell/bar/widgets/Tray.qml
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import "../../theme/"

Row {
    spacing: Style.bar.tray.spacing

    Repeater {
        model: SystemTray.items

        IconImage {
            required property var modelData
            implicitSize: Style.bar.tray.iconSize
            source: modelData.icon
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                onClicked: modelData.activate()
            }
        }
    }
}
