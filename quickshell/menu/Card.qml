// quickshell/menu/Card.qml
// The visible card: a title taken from the file name, the filter box when
// the menu has one, and the row list. Height is padding, title, gap, the box
// and up to maxRows rows, capped by maxHeight; past that the list scrolls.
// Every size comes from Style.menu, already scaled; only the literal gap
// still goes through Style.space.
import QtQuick
import "../theme/"

Rectangle {
    id: root

    required property Model menu
    property int maxHeight: 700

    readonly property int padding: Style.menu.card.padding
    readonly property int gap: Style.space(8)
    readonly property int chrome: padding * 2 + title.height + gap + (search.visible ? search.height + gap : 0)

    signal closeRequested

    function focusList() {
        if (search.visible)
            search.focusInput();
        else
            list.forceActiveFocus();
    }

    implicitWidth: Style.menu.card.width
    implicitHeight: chrome + list.height

    color: Colors.menu.background
    radius: Style.menu.card.radius
    border.width: Style.menu.card.border
    border.color: Colors.menu.border

    Column {
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: root.gap

        Text {
            id: title
            // "system.json" -> "system"
            text: root.menu.file.path.split("/").pop().replace(/\.json$/, "")
            color: Colors.menu.title
            font.family: Style.menu.font.family
            font.pixelSize: Style.menu.font.title
        }

        Search {
            id: search
            width: parent.width
            visible: root.menu.filterable
            menu: root.menu
            list: list
            // A command menu's entries arrive after it opens: the box may
            // appear while the list already holds the keyboard.
            onVisibleChanged: root.focusList()
        }

        List {
            id: list
            width: parent.width
            height: Math.min(Math.max(1, Math.min(count, Style.menu.list.maxRows)) * Style.menu.rowHeight, root.maxHeight - root.chrome)
            menu: root.menu
            onActivated: index => {
                if (root.menu.activate(index))
                    root.closeRequested();
            }
            onCloseRequested: root.closeRequested()
        }
    }
}
