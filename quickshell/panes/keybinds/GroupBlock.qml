// quickshell/panes/keybinds/GroupBlock.qml
// One group of a section: its heading, then one row per bind.
import QtQuick
import "../../theme/"
import "keymodel.js" as KeyModel

Column {
    id: root

    required property var group
    property string query: ""

    spacing: Style.space(1)

    Text {
        width: root.width
        bottomPadding: Style.space(4)
        text: KeyModel.highlight(String(root.group.title).toUpperCase(), root.query, Colors.keybinds.text)
        textFormat: Text.StyledText
        elide: Text.ElideRight
        color: Colors.keybinds.match
        font.family: Style.keybinds.font.family
        font.pixelSize: Style.keybinds.font.caption
        font.bold: true
        font.letterSpacing: 1.2
    }

    Repeater {
        model: root.group.binds

        BindRow {
            required property var modelData

            width: root.width
            bind: modelData
            query: root.query
        }
    }
}
