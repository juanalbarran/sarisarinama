// quickshell/panes/keybinds/BindRow.qml
// One bind: its keys on the left, in their share of the column, and what
// it does on the right, the filter's matches picked out in both. Washed
// under the pointer, to follow a row across the gap.
import QtQuick
import "../../theme/"
import "keymodel.js" as KeyModel

Rectangle {
    id: root

    required property var bind
    property string query: ""

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
        query: root.query
    }

    Text {
        id: label
        anchors.left: combo.right
        anchors.leftMargin: Style.keybinds.row.gap
        anchors.right: parent.right
        anchors.rightMargin: Style.space(4)
        anchors.verticalCenter: parent.verticalCenter
        text: KeyModel.highlight(root.bind.description, root.query, Colors.keybinds.match)
        textFormat: Text.StyledText
        wrapMode: Text.Wrap
        color: Colors.keybinds.text
        font.family: Style.keybinds.font.family
        font.pixelSize: Style.keybinds.font.body
    }
}
