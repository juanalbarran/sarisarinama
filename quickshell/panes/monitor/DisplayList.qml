// quickshell/panes/monitor/DisplayList.qml
// Every display the compositor knows, the ones that are off too, the
// laptop first. A laptop has two or three at most, so the list never
// scrolls.
import QtQuick
import "../../theme/"

Column {
    id: root

    required property MonState mon
    required property Cursor cursor

    spacing: Style.monitor.list.spacing

    Text {
        text: "DISPLAYS"
        color: Colors.monitor.muted
        font.family: Style.monitor.font.family
        font.pixelSize: Style.monitor.font.caption
        font.bold: true
        font.letterSpacing: 1.2
    }

    Repeater {
        model: root.mon.outputs

        DisplayRow {
            required property var modelData

            width: root.width
            output: modelData
            mon: root.mon
            cursor: root.cursor
        }
    }
}
