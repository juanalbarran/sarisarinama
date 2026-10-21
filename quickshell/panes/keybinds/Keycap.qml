// quickshell/panes/keybinds/Keycap.qml
// One key, drawn as a keycap: a face over a darker lower edge, so it reads
// as something to press. Never narrower than it is tall.
import QtQuick
import "../../theme/"

Item {
    id: root

    property string text: ""

    implicitWidth: Math.max(label.implicitWidth + 2 * Style.keybinds.keycap.paddingX, face.height)
    implicitHeight: label.implicitHeight + 2 * Style.keybinds.keycap.paddingY + Style.keybinds.keycap.depth

    Rectangle {
        anchors.fill: parent
        radius: Style.keybinds.keycap.radius
        color: Colors.keybinds.keycapEdge
    }

    Rectangle {
        id: face
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height - Style.keybinds.keycap.depth
        radius: Style.keybinds.keycap.radius
        color: Colors.keybinds.keycap
        border.width: Style.keybinds.card.border
        border.color: Colors.keybinds.keycapEdge

        Text {
            id: label
            anchors.centerIn: parent
            text: root.text
            color: Colors.keybinds.keycapText
            font.family: Style.keybinds.font.family
            font.pixelSize: Style.keybinds.font.caption
            font.bold: true
        }
    }
}
