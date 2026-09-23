// quickshell/bar/widgets/Network.qml
import Quickshell.Io
import QtQuick
import "../../theme/"

Text {
    property string icon: "\udb83\udc9c"   // disconnected

    text: icon
    color: Colors.text
    font.family: Style.font.family
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

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: nmcli.running = true
    }
}
