// quickshell/bar/widgets/Network.qml
import Quickshell.Io
import QtQuick
import "../../theme/"

Text {
    id: root

    signal clicked

    property string icon: "\udb83\udc9c"   // disconnected

    text: icon
    color: Colors.bar.text
    font.family: Style.bar.font.family
    font.pixelSize: Style.bar.textSize("network", "body")

    Process {
        id: nmcli
        command: ["nmcli", "-t", "-f", "TYPE", "connection", "show", "--active"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const types = text.trim().split("\n");
                icon = types.some(t => t.includes("ethernet")) ? "\udb80\ude00" : types.some(t => t.includes("wireless")) ? "\uf1eb" : "\udb83\udc9c";
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: nmcli.running = true
    }
}
