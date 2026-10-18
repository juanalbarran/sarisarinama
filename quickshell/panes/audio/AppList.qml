// quickshell/panes/audio/AppList.qml
// Every app playing sound, each with its own volume. With none, it says so.
import QtQuick
import "../../theme/"

Column {
    id: root

    required property AudioState audio
    required property Cursor cursor

    spacing: Style.audio.list.spacing

    Text {
        text: "APPS"
        color: Colors.audio.muted
        font.family: Style.audio.font.family
        font.pixelSize: Style.audio.font.caption
        font.bold: true
        font.letterSpacing: 1.2
    }

    Text {
        width: root.width
        visible: root.audio.appRows.length === 0
        text: "Nothing is playing"
        color: Colors.audio.muted
        font.family: Style.audio.font.family
        font.pixelSize: Style.audio.font.body
    }

    Repeater {
        model: root.audio.appRows

        AppRow {
            required property var modelData

            width: root.width
            row: modelData
            audio: root.audio
            cursor: root.cursor
        }
    }
}
