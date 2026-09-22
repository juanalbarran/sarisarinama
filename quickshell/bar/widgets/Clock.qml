// quickshell/bar/widgets/Clock.qml
import Quickshell
import QtQuick
import "../../theme/"

Text {
    SystemClock {
        id: clock
    }

    text: Qt.formatDateTime(clock.date, "HH:mm | ddd, dd")
    color: Colors.text
    font.family: "JetBrains Mono Nerd Font"
    font.pixelSize: 14
}
