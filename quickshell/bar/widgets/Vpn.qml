// quickshell/bar/widgets/Vpn.qml
import Quickshell.Io
import QtQuick
import "../../theme/"

Text {
    id: root

    signal clicked

    // A plugin VPN is type "vpn", a WireGuard tunnel "wireguard".
    property bool connected: false

    text: "\u{f0582}"
    color: mouse.containsMouse ? Colors.bar.hover : connected ? Colors.bar.focused : Colors.bar.text
    font.family: Style.bar.font.family
    font.pixelSize: Style.bar.textSize("vpn", "body")

    Process {
        id: nmcli
        command: ["nmcli", "-t", "-f", "TYPE", "connection", "show", "--active"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const types = text.trim().split("\n");
                connected = types.some(t => t === "vpn" || t === "wireguard");
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
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
