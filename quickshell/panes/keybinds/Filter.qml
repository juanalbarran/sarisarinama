// quickshell/panes/keybinds/Filter.qml
// The filter box: whatever is typed narrows the section to the binds that
// match. It holds the keyboard while the pane is open, so the pane's own
// keys (Tab, Ctrl+N, Escape…) are offered to `panel` before the text sees
// them.
import QtQuick
import "../../theme/"

Rectangle {
    id: root

    required property KeybindsState keys
    // Anything with handleKey(event), which accepts the keys it uses.
    required property var panel

    function focusInput() {
        input.forceActiveFocus();
    }

    implicitHeight: input.implicitHeight + 2 * Style.keybinds.row.paddingY
    radius: Style.keybinds.row.radius
    color: Colors.keybinds.keycap
    border.width: Style.keybinds.card.border
    border.color: input.text !== "" ? Colors.keybinds.match : Colors.keybinds.separator

    Text {
        id: glyph
        anchors.left: parent.left
        anchors.leftMargin: Style.keybinds.row.paddingX
        anchors.verticalCenter: parent.verticalCenter
        text: ""
        color: input.text !== "" ? Colors.keybinds.match : Colors.keybinds.muted
        font.family: Style.keybinds.font.family
        font.pixelSize: Style.keybinds.font.body
    }

    TextInput {
        id: input
        anchors.left: glyph.right
        anchors.leftMargin: Style.keybinds.row.gap
        anchors.right: parent.right
        anchors.rightMargin: Style.keybinds.row.paddingX
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        color: Colors.keybinds.text
        selectionColor: Colors.keybinds.current
        font.family: Style.keybinds.font.family
        font.pixelSize: Style.keybinds.font.body

        onTextChanged: root.keys.query = text
        Keys.onPressed: event => root.panel.handleKey(event)

        // Opening the pane clears the query; the box follows.
        Connections {
            target: root.keys
            function onQueryChanged() {
                if (input.text !== root.keys.query)
                    input.text = root.keys.query;
            }
        }
    }

    Text {
        anchors.fill: input
        verticalAlignment: Text.AlignVCenter
        visible: input.text === ""
        text: "Type to filter"
        color: Colors.keybinds.muted
        font.family: Style.keybinds.font.family
        font.pixelSize: Style.keybinds.font.body
    }
}
