// quickshell/panes/keybinds/BindRow.qml
// One bind: its keys on the left, in their share of the column, and what
// it does on the right. Washed under the pointer, to follow a row across
// the gap.
import QtQuick
import "../../theme/"

Rectangle {
    id: root

    required property var bind

    implicitHeight: Math.max(combo.implicitHeight, label.implicitHeight) + 2 * Style.space(3)
    radius: Style.keybinds.row.radius
    color: hover.hovered ? Colors.keybinds.hover : "transparent"

    HoverHandler {
        id: hover
    }

    KeyCombo {
        id: combo
        anchors.left: parent.left
        anchors.leftMargin: Style.space(4)
        anchors.verticalCenter: parent.verticalCenter
        width: Math.round(root.width * Style.keybinds.columns.keysWidth) - Style.space(4)
        keys: root.bind.keys
    }

    Text {
        id: label
        anchors.left: combo.right
        anchors.leftMargin: Style.keybinds.row.gap
        anchors.right: parent.right
        anchors.rightMargin: Style.space(4)
        anchors.verticalCenter: parent.verticalCenter
        text: root.bind.description
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        color: Colors.keybinds.text
        font.family: Style.keybinds.font.family
        font.pixelSize: Style.keybinds.font.body
    }
}
