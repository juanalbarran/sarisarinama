// quickshell/panes/monitor/DisplayRow.qml
// One display: its icon, its name, its mode and scale or Off, and on the
// right its switch. Enter, or a click on the switch, turns it on or off.
// The last display that is on has its switch greyed out: MonState will
// not turn it off.
import QtQuick
import "../../theme/"
import "../common/"
import "monmodel.js" as MonModel

Rectangle {
    id: root

    required property var output
    required property MonState mon
    required property Cursor cursor

    readonly property string lineId: "out:" + output.name
    readonly property bool selected: cursor.at(lineId, 0)

    implicitHeight: Math.max(icon.implicitHeight, labels.implicitHeight, toggle.implicitHeight) + 2 * Style.monitor.row.paddingY
    radius: Style.monitor.row.radius
    color: root.selected ? Colors.monitor.hover : (root.output.focused ? Colors.monitor.current : "transparent")

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.cursor.select(root.lineId, 0)
    }

    Text {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: Style.monitor.row.paddingX
        anchors.verticalCenter: parent.verticalCenter
        text: MonModel.icon(root.output)
        color: root.output.active ? Colors.monitor.text : Colors.monitor.muted
        font.family: Style.monitor.font.family
        font.pixelSize: Style.monitor.font.title
    }

    Column {
        id: labels
        anchors.left: icon.right
        anchors.leftMargin: Style.monitor.row.gap
        anchors.right: toggle.left
        anchors.rightMargin: Style.monitor.row.gap
        anchors.verticalCenter: parent.verticalCenter

        Text {
            width: parent.width
            text: MonModel.title(root.output)
            elide: Text.ElideRight
            color: root.output.active ? Colors.monitor.text : Colors.monitor.muted
            font.family: Style.monitor.font.family
            font.pixelSize: Style.monitor.font.body
        }

        Text {
            width: parent.width
            text: MonModel.detail(root.output)
            elide: Text.ElideRight
            color: Colors.monitor.muted
            font.family: Style.monitor.font.family
            font.pixelSize: Style.monitor.font.caption
        }
    }

    Toggle {
        id: toggle
        panelStyle: Style.monitor
        panelColors: Colors.monitor
        anchors.right: parent.right
        anchors.rightMargin: Style.monitor.row.paddingX
        anchors.verticalCenter: parent.verticalCenter
        checked: root.output.active
        enabled: root.mon.canToggle(root.output)
        opacity: enabled ? 1.0 : 0.5
        onToggled: root.mon.toggle(root.output.name)
        onHovered: root.cursor.select(root.lineId, 0)
    }
}
