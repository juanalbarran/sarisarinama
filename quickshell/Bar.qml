// quickshell/Bar.qml
import Quickshell
import QtQuick

PanelWindow {
    anchors {
        bottom: true
        left: true
        right: true
    }
    implicitHeight: 30
    color: Colors.background

    // left — workspaces will live here
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        Workspaces {}
    }

    // center
    Clock {
        anchors.centerIn: parent
    }

    // right — audio / network / battery will live here
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Tray {
            anchors.verticalCenter: parent.verticalCenter
        }
        Audio {
            anchors.verticalCenter: parent.verticalCenter
        }
        Network {
            anchors.verticalCenter: parent.verticalCenter
        }
        Battery {
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
