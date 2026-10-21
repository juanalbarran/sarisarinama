// quickshell/panes/keybinds/KeyCombo.qml
// A bind's keys: each chord a row of keycaps joined by a small +, the
// chords one after the other with a wider gap. A {placeholder} is written
// in italics instead of on a key: it is something to type. Wraps when the
// keys are wider than their share of the column.
import QtQuick
import "../../theme/"
import "keymodel.js" as KeyModel

Flow {
    id: root

    property string keys: ""

    spacing: Style.keybinds.keycap.stepGap

    Repeater {
        model: KeyModel.steps(root.keys)

        Row {
            id: chord

            required property var modelData

            spacing: Style.keybinds.keycap.gap

            Repeater {
                model: chord.modelData

                Row {
                    id: key

                    required property string modelData
                    required property int index

                    spacing: Style.keybinds.keycap.gap

                    Text {
                        visible: key.index > 0
                        anchors.verticalCenter: parent.verticalCenter
                        text: "+"
                        color: Colors.keybinds.muted
                        font.family: Style.keybinds.font.family
                        font.pixelSize: Style.keybinds.font.caption
                    }

                    Keycap {
                        visible: !KeyModel.isPlaceholder(key.modelData)
                        text: key.modelData
                    }

                    Text {
                        visible: KeyModel.isPlaceholder(key.modelData)
                        anchors.verticalCenter: parent.verticalCenter
                        text: KeyModel.placeholderText(key.modelData)
                        color: Colors.keybinds.muted
                        font.family: Style.keybinds.font.family
                        font.pixelSize: Style.keybinds.font.caption
                        font.italic: true
                    }
                }
            }
        }
    }
}
