// quickshell/bar/widgets/Clock.qml
import Quickshell
import QtQuick
import "../../theme/"

Text {
    SystemClock {
        id: clock
    }

    text: Qt.formatDateTime(clock.date, "HH:mm | ddd, dd")
    color: Colors.bar.text
    font.family: Style.bar.font.family
    font.pixelSize: Style.bar.textSize("clock", "title")
}
