// quickshell/panes/audio/AppRow.qml
// One app playing sound: its name over its own volume slider. h and l
// nudge it, Enter, or a click on its icon, mutes it. Like DeviceRow it
// holds an id and a name, never the node.
import QtQuick
import "../../theme/"
import "audiomodel.js" as AudioModel

Item {
    id: root

    required property var row
    required property AudioState audio
    required property Cursor cursor

    readonly property var node: audio.nodeFor(row)
    readonly property string lineId: "app:" + row.id
    readonly property bool muted: !!(node && node.audio && node.audio.muted)
    readonly property real volume: node && node.audio ? node.audio.volume : 0

    implicitHeight: name.implicitHeight + slider.implicitHeight + 2 * Style.audio.row.paddingY

    Text {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: Style.audio.row.paddingX
        anchors.verticalCenter: parent.verticalCenter
        text: AudioModel.volumeIcon(root.volume, root.muted)
        color: root.muted ? Colors.audio.muted : Colors.audio.text
        font.family: Style.audio.font.family
        font.pixelSize: Style.audio.font.title

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.audio.toggleMute(root.node)
        }
    }

    Text {
        id: name
        anchors.top: parent.top
        anchors.topMargin: Style.audio.row.paddingY
        anchors.left: icon.right
        anchors.leftMargin: Style.audio.row.gap
        anchors.right: percent.left
        anchors.rightMargin: Style.audio.row.gap
        text: AudioModel.appLabel(root.node)
        elide: Text.ElideRight
        color: root.muted ? Colors.audio.muted : Colors.audio.text
        font.family: Style.audio.font.family
        font.pixelSize: Style.audio.font.body
    }

    VolumeSlider {
        id: slider
        anchors.top: name.bottom
        anchors.left: name.left
        anchors.right: name.right
        value: root.volume
        muted: root.muted
        hasCursor: root.cursor.at(root.lineId, 0)
        onMoved: v => root.audio.setVolume(root.node, v)
        onHovered: root.cursor.select(root.lineId, 0)
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
        anchors.verticalCenter: slider.verticalCenter
        width: widest.width
        horizontalAlignment: Text.AlignRight
        text: AudioModel.percent(root.volume)
        color: root.muted ? Colors.audio.muted : Colors.audio.text
        font.family: Style.audio.font.family
        font.pixelSize: Style.audio.font.body
    }
}
