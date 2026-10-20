// quickshell/panes/keybinds/Keycap.qml
// One key, drawn as a keycap: a face over a darker lower edge, so it reads
// as something to press. Never narrower than it is tall. Ringed in the
// match colour when the filter found it.
import QtQuick
import "../../theme/"

Item {
    id: root

    property string text: ""
    property bool lit: false

    implicitWidth: Math.max(label.implicitWidth + 2 * Style.keybinds.keycap.paddingX, face.height)
    implicitHeight: label.implicitHeight + 2 * Style.keybinds.keycap.paddingY + Style.keybinds.keycap.depth

    Rectangle {
        anchors.fill: parent
        radius: Style.keybinds.keycap.radius
        color: root.lit ? Colors.keybinds.match : Colors.keybinds.keycapEdge
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
        border.color: root.lit ? Colors.keybinds.match : Colors.keybinds.keycapEdge

        Text {
            id: label
            anchors.centerIn: parent
            text: root.text
            color: root.lit ? Colors.keybinds.match : Colors.keybinds.keycapText
            font.family: Style.keybinds.font.family
            font.pixelSize: Style.keybinds.font.caption
            font.bold: true
        }
    }
}
