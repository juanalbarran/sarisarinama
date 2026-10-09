// quickshell/panes/network/PillRow.qml
// One setting as a heading and a row of pills, one per choice. The band
// row and the DNS row are both this; what a choice means is up to whoever
// listens to `picked`. The row is one cursor line, and each pill a stop.
import QtQuick
import "../../theme/"

Column {
    id: root

    required property Cursor cursor
    required property string lineId

    property string title: ""
    // The heading turns red when it is reporting a failure.
    property bool failed: false
    // [{id, label}], in order.
    property var options: []
    property string current: ""
    property bool busy: false

    signal picked(string id)

    spacing: Style.network.list.spacing

    Text {
        width: parent.width
        text: root.title
        elide: Text.ElideRight
        color: root.failed ? Colors.network.urgent : Colors.network.muted
        font.family: Style.network.font.family
        font.pixelSize: Style.network.font.caption
        font.bold: true
        font.letterSpacing: 1.2
    }

    Flow {
        width: parent.width
        spacing: Style.network.pill.gap

        Repeater {
            model: root.options

            Pill {
                required property var modelData
                required property int index

                text: modelData.label
                active: modelData.id === root.current
                hasCursor: root.cursor.at(root.lineId, index)
                enabled: !root.busy
                onHovered: root.cursor.select(root.lineId, index)
                onClicked: root.picked(modelData.id)
            }
        }
    }
}
