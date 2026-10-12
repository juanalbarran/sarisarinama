// quickshell/panes/common/PillRow.qml
// One setting as a heading and a row of pills, one per choice. What a
// choice means is up to whoever listens to `picked`. The row is one cursor
// line, and each pill a stop: `cursor` is the panel's own, anything with
// at(line, stop) and select(line, stop).
import QtQuick
import "../../theme/"

Column {
    id: root

    required property PanelStyle panelStyle
    required property PanelColors panelColors
    required property var cursor
    required property string lineId

    property string title: ""
    // The heading turns red when it is reporting a failure.
    property bool failed: false
    // [{id, label}], in order.
    property var options: []
    property string current: ""
    property bool busy: false

    signal picked(string id)

    spacing: root.panelStyle.list.spacing

    Text {
        width: parent.width
        text: root.title
        elide: Text.ElideRight
        color: root.failed ? root.panelColors.urgent : root.panelColors.muted
        font.family: root.panelStyle.font.family
        font.pixelSize: root.panelStyle.font.caption
        font.bold: true
        font.letterSpacing: 1.2
    }

    Flow {
        width: parent.width
        spacing: root.panelStyle.pill.gap

        Repeater {
            model: root.options

            Pill {
                required property var modelData
                required property int index

                panelStyle: root.panelStyle
                panelColors: root.panelColors
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
