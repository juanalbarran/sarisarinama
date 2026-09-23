// quickshell/menu/Card.qml
// The visible card: a title taken from the file name, plus the row list.
// Height is padding, title, gap and one row per entry, capped by maxHeight;
// past the cap the list scrolls. Every size comes from Style.
import QtQuick
import "../theme/"

Rectangle {
    id: root

    required property Model menu
    property int maxHeight: 700

    readonly property int padding: Style.space(Style.card.padding)
    readonly property int gap: Style.space(8)
    readonly property int chrome: padding * 2 + title.height + gap

    signal closeRequested

    function focusList() {
        list.forceActiveFocus();
    }

    implicitWidth: Style.space(Style.card.width)
    implicitHeight: chrome + list.height

    color: Colors.background
    radius: Style.card.radius
    border.width: Style.card.border
    border.color: Colors.accent

    Column {
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: root.gap

        Text {
            id: title
            // "system.json" -> "system"
            text: root.menu.file.path.split("/").pop().replace(/\.json$/, "")
            color: Colors.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.title
        }

        List {
            id: list
            width: parent.width
            height: Math.min(Math.max(1, count) * Style.rowHeight, root.maxHeight - root.chrome)
            menu: root.menu
            onActivated: index => {
                if (root.menu.activate(index))
                    root.closeRequested();
            }
            onCloseRequested: root.closeRequested()
        }
    }
}
