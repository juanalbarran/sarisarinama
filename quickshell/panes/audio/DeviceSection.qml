// quickshell/panes/audio/DeviceSection.qml
// One direction of sound, output or input: its heading, the volume of the
// default device as a slider, and every device of that kind to pick the
// default from. The icon beside the slider mutes it, as Enter on it does.
import QtQuick
import "../../theme/"
import "audiomodel.js" as AudioModel

Column {
    id: root

    required property AudioState audio
    required property Cursor cursor
    // "out" or "in".
    required property string kind

    readonly property bool output: kind === "out"
    readonly property var node: output ? audio.sink : audio.source
    readonly property var rows: output ? audio.outputRows : audio.inputRows
    readonly property bool muted: !!(node && node.audio && node.audio.muted)
    readonly property real volume: node && node.audio ? node.audio.volume : 0

    visible: node !== null || rows.length > 0
    spacing: Style.audio.list.spacing

    Text {
        text: root.output ? "OUTPUT" : "INPUT"
        color: Colors.audio.muted
        font.family: Style.audio.font.family
        font.pixelSize: Style.audio.font.caption
        font.bold: true
        font.letterSpacing: 1.2
    }

    Item {
        width: root.width
        visible: root.node !== null
        implicitHeight: Math.max(icon.implicitHeight, slider.implicitHeight) + 2 * Style.audio.row.paddingY

        Text {
            id: icon
            anchors.left: parent.left
            anchors.leftMargin: Style.audio.row.paddingX
            anchors.verticalCenter: parent.verticalCenter
            text: root.output ? AudioModel.volumeIcon(root.volume, root.muted) : AudioModel.micIcon(root.muted)
            color: root.muted ? Colors.audio.muted : Colors.audio.text
            font.family: Style.audio.font.family
            font.pixelSize: Style.audio.font.title

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.audio.toggleMute(root.node)
            }
        }

        VolumeSlider {
            id: slider
            anchors.left: icon.right
            anchors.leftMargin: Style.audio.row.gap
            anchors.right: percent.left
            anchors.rightMargin: Style.audio.row.gap
            anchors.verticalCenter: parent.verticalCenter
            value: root.volume
            muted: root.muted
            hasCursor: root.cursor.at(root.kind + ":vol", 0)
            onMoved: v => root.audio.setVolume(root.node, v)
            onHovered: root.cursor.select(root.kind + ":vol", 0)
        }

        // As wide as "100%", so the slider does not jump as the digits change.
        TextMetrics {
            id: widest
            font: percent.font
            text: "100%"
        }

        Text {
            id: percent
            anchors.right: parent.right
            anchors.rightMargin: Style.audio.row.paddingX
            anchors.verticalCenter: parent.verticalCenter
            width: widest.width
            horizontalAlignment: Text.AlignRight
            text: AudioModel.percent(root.volume)
            color: root.muted ? Colors.audio.muted : Colors.audio.text
            font.family: Style.audio.font.family
            font.pixelSize: Style.audio.font.body
        }
    }

    Repeater {
        model: root.rows

        DeviceRow {
            required property var modelData

            width: root.width
            row: modelData
            kind: root.kind
            audio: root.audio
            cursor: root.cursor
        }
    }
}
