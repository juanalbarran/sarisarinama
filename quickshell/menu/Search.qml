// quickshell/menu/Search.qml
// The filter box: what is typed becomes the model's query. It holds the
// keyboard while shown, so the keys the list answers to (Ctrl+N, Ctrl+P,
// Enter, Escape) are handed to the list before the text sees them.
import QtQuick
import "../theme/"

Rectangle {
    id: root

    required property Model menu
    required property List list

    function focusInput() {
        input.forceActiveFocus();
    }

    implicitHeight: Style.menu.rowHeight
    radius: Style.menu.card.radius
    color: Colors.menu.selectedBackground

    TextInput {
        id: input
        anchors.fill: parent
        leftPadding: Style.menu.row.paddingX
        rightPadding: Style.menu.row.paddingX
        verticalAlignment: TextInput.AlignVCenter
        clip: true
        color: Colors.menu.text
        font.family: Style.menu.font.family
        font.pixelSize: Style.menu.font.body

        onTextChanged: root.menu.query = text
        Keys.onPressed: event => root.list.handleKey(event)

        // A new menu clears the query; the box follows.
        Connections {
            target: root.menu
            function onQueryChanged() {
                if (input.text !== root.menu.query)
                    input.text = root.menu.query;
            }
        }
    }

    Text {
        anchors.fill: parent
        leftPadding: Style.menu.row.paddingX
        verticalAlignment: Text.AlignVCenter
        visible: input.text === ""
        text: "Filter"
        color: Colors.menu.placeholder
        font.family: Style.menu.font.family
        font.pixelSize: Style.menu.font.body
    }
}
