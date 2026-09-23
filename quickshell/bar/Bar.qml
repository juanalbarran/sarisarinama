// quickshell/bar/Bar.qml
// The bar window. Geometry comes from Style.bar, colors from Colors; each
// widget sizes its own text. Nothing here is a literal.
import Quickshell
import QtQuick
import "../theme/"
import "./widgets/"

PanelWindow {
    anchors {
        bottom: true
        left: true
        right: true
    }
    implicitHeight: Style.bar.height
    color: Colors.background

    // left — workspaces bring their own spacing
    Row {
        anchors.left: parent.left
        anchors.leftMargin: Style.bar.paddingLeft
        anchors.verticalCenter: parent.verticalCenter
        Workspaces {}
    }

    // center
    Clock {
        anchors.centerIn: parent
    }

    // right — tray, audio, network, battery
    Row {
        anchors.right: parent.right
        anchors.rightMargin: Style.bar.paddingRight
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.bar.spacing

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
