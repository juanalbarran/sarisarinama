// quickshell/panes/keybinds/Header.qml
// The top row: the section's icon and name, how many binds it has (or how
// many the filter left), and on the right one pill per section, the one in
// view filled. A click on a pill shows that section.
import QtQuick
import "../../theme/"
import "../common/"

Item {
    id: root

    required property KeybindsState keys

    signal picked(string id)

    implicitHeight: Math.max(icon.implicitHeight, labels.implicitHeight, tabs.implicitHeight)

    Text {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.keys.section ? String(root.keys.section.icon).trim() : "󰌌"
        color: Colors.keybinds.accent
        font.family: Style.keybinds.font.family
        font.pixelSize: Style.keybinds.hero.iconSize
    }

    Column {
        id: labels
        anchors.left: icon.right
        anchors.leftMargin: Style.keybinds.hero.gap
        anchors.right: tabs.left
        anchors.rightMargin: Style.keybinds.hero.gap
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(2)

        Text {
            width: parent.width
            text: root.keys.section ? root.keys.section.label : "Keybinds"
            elide: Text.ElideRight
            color: Colors.keybinds.text
            font.family: Style.keybinds.font.family
            font.pixelSize: Style.keybinds.font.title
            font.bold: true
        }

        Text {
            width: parent.width
            text: {
                if (!root.keys.section)
                    return "NOTHING TO SHOW";
                if (root.keys.query.trim() !== "")
                    return root.keys.shown + " OF " + root.keys.total + " KEYBINDS";
                return root.keys.total + " KEYBINDS";
            }
            elide: Text.ElideRight
            color: Colors.keybinds.muted
            font.family: Style.keybinds.font.family
            font.pixelSize: Style.keybinds.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }
    }

    Row {
        id: tabs
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.keybinds.pill.gap
        // One section needs no tabs.
        visible: root.keys.sections.length > 1

        Repeater {
            model: root.keys.sections

            Pill {
                required property var modelData

                panelStyle: Style.keybinds
                panelColors: Colors.keybinds
                text: modelData.label
                active: modelData.id === root.keys.section?.id
                onClicked: root.picked(modelData.id)
            }
        }
    }
}
