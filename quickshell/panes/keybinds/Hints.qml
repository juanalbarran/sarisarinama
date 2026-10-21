// quickshell/panes/keybinds/Hints.qml
// The bottom line: the pane's own keys, drawn as keycaps like the binds.
import QtQuick
import "../../theme/"

Row {
    id: root

    // Tabs make sense with more than one section.
    property bool tabs: true

    spacing: Style.keybinds.columns.gap

    Repeater {
        model: [
            {
                keys: "Tab",
                label: "next app",
                show: root.tabs
            },
            {
                keys: "j k",
                label: "scroll",
                show: true
            },
            {
                keys: "Esc",
                label: "close",
                show: true
            }
        ].filter(h => h.show)

        Row {
            id: hint

            required property var modelData

            spacing: Style.keybinds.row.gap

            KeyCombo {
                anchors.verticalCenter: parent.verticalCenter
                keys: hint.modelData.keys
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: hint.modelData.label
                color: Colors.keybinds.muted
                font.family: Style.keybinds.font.family
                font.pixelSize: Style.keybinds.font.caption
            }
        }
    }
}
