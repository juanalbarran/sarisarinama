// quickshell/menu/Card.qml
// The visible card: a title taken from the file name, plus the row list.
import QtQuick
import "../theme/"

Rectangle {
    id: root

    required property Model menu

    signal closeRequested

    function focusList() {
        list.forceActiveFocus();
    }

    color: Colors.background
    radius: 8
    border.color: Colors.accent

    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Text {
            id: title
            // "system.json" -> "system"
            text: root.menu.file.path.split("/").pop().replace(/\.json$/, "")
            color: Colors.accent
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 12
        }

        List {
            id: list
            width: parent.width
            height: parent.height - title.height - parent.spacing
            menu: root.menu
            onActivated: index => {
                if (root.menu.activate(index))
                    root.closeRequested();
            }
            onCloseRequested: root.closeRequested()
        }
    }
}
