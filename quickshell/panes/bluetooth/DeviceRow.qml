// quickshell/panes/bluetooth/DeviceRow.qml
// One device in the list: its kind, its name and what is happening to it,
// and on the right Forget for a device BlueZ remembers. A click connects,
// disconnects or pairs it; BtModel.actionFor decides which.
import QtQuick
import "../../theme/"
import "btmodel.js" as BtModel

Column {
    id: root

    // Set by the Repeater: the row's plain values and its position.
    required property var modelData
    required property int index
    required property BtState bt
    required property Cursor cursor

    readonly property var row: modelData
    readonly property string lineId: "dev:" + row.address
    readonly property bool selected: cursor.at(lineId, 0)
    readonly property bool forgetSelected: cursor.at(lineId, 1)
    readonly property string busyKind: bt.actionAddress === row.address ? bt.actionKind : ""
    readonly property string failedKind: bt.failures[row.address] ?? ""
    readonly property bool forgettable: BtModel.canForget(row)
    readonly property string status: BtModel.status(row, busyKind, failedKind)

    spacing: Style.bluetooth.list.spacing

    Text {
        visible: root.row.heading !== ""
        topPadding: root.index > 0 ? Style.bluetooth.gap : 0
        text: root.row.heading
        color: Colors.bluetooth.muted
        font.family: Style.bluetooth.font.family
        font.pixelSize: Style.bluetooth.font.caption
        font.bold: true
        font.letterSpacing: 1.2
    }

    Rectangle {
        width: parent.width
        implicitHeight: Math.max(icon.implicitHeight, labels.implicitHeight) + 2 * Style.bluetooth.row.paddingY
        radius: Style.bluetooth.row.radius
        color: root.selected && !root.bt.busy ? Colors.bluetooth.hover : (root.row.connected ? Colors.bluetooth.current : "transparent")

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: !root.bt.busy
            cursorShape: Qt.PointingHandCursor
            onEntered: root.cursor.select(root.lineId, 0)
            onClicked: root.bt.act(root.row)
        }

        Text {
            id: icon
            anchors.left: parent.left
            anchors.leftMargin: Style.bluetooth.row.paddingX
            anchors.verticalCenter: parent.verticalCenter
            text: BtModel.glyph(root.row.icon)
            color: root.failedKind !== "" ? Colors.bluetooth.urgent : (root.row.connected ? Colors.bluetooth.accent : Colors.bluetooth.text)
            font.family: Style.bluetooth.font.family
            font.pixelSize: Style.bluetooth.font.title
        }

        Column {
            id: labels
            anchors.left: icon.right
            anchors.leftMargin: Style.bluetooth.row.gap
            anchors.right: side.visible ? side.left : parent.right
            anchors.rightMargin: side.visible ? Style.bluetooth.row.gap : Style.bluetooth.row.paddingX
            anchors.verticalCenter: parent.verticalCenter

            Text {
                width: parent.width
                text: root.row.name
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: Colors.bluetooth.text
                font.family: Style.bluetooth.font.family
                font.pixelSize: Style.bluetooth.font.body
            }

            Text {
                width: parent.width
                visible: root.status !== ""
                text: root.status
                elide: Text.ElideRight
                color: root.failedKind !== "" ? Colors.bluetooth.urgent : Colors.bluetooth.muted
                font.family: Style.bluetooth.font.family
                font.pixelSize: Style.bluetooth.font.caption
            }
        }

        Text {
            id: side
            anchors.right: parent.right
            anchors.rightMargin: Style.bluetooth.row.paddingX
            anchors.verticalCenter: parent.verticalCenter
            visible: root.forgettable && (root.selected || root.forgetSelected || rowMouse.containsMouse || sideMouse.containsMouse)
            text: "󰅙"
            color: Colors.bluetooth.urgent
            font.family: Style.bluetooth.font.family
            font.pixelSize: Style.bluetooth.font.title

            // The cursor on Forget; z -1 draws it behind the glyph.
            Rectangle {
                z: -1
                anchors.centerIn: parent
                width: parent.width + 2 * Style.bluetooth.row.paddingY
                height: width
                radius: Style.bluetooth.row.radius
                color: Colors.bluetooth.hover
                visible: root.forgetSelected && !root.bt.busy
            }

            // Declared after rowMouse, so it sits on top and takes the click.
            MouseArea {
                id: sideMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: root.forgettable && !root.bt.busy
                cursorShape: Qt.PointingHandCursor
                onEntered: root.cursor.select(root.lineId, 1)
                onClicked: root.bt.forget(root.row)
            }
        }
    }
}
