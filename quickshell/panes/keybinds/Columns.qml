// quickshell/panes/keybinds/Columns.qml
// The section's groups, spread over style.keybinds.columns.count columns
// in reading order: down the first column, then the next.
import QtQuick
import "../../theme/"
import "keymodel.js" as KeyModel

Row {
    id: root

    required property KeybindsState keys

    readonly property var columns: KeyModel.columns(keys.groups, Style.keybinds.columns.count)
    readonly property int count: Math.max(1, Style.keybinds.columns.count)
    readonly property real columnWidth: (width - spacing * (count - 1)) / count

    spacing: Style.keybinds.columns.gap

    Repeater {
        model: root.columns

        Column {
            id: column

            required property var modelData

            width: root.columnWidth
            spacing: Style.keybinds.columns.groupGap

            Repeater {
                model: column.modelData

                GroupBlock {
                    required property var modelData

                    width: column.width
                    group: modelData
                }
            }
        }
    }
}
