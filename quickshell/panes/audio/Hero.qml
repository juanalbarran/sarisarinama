// quickshell/panes/audio/Hero.qml
// The top row of the panel: the speaker, the output in use, its volume,
// and a switch that mutes it. Everything it shows is read from AudioState.
import QtQuick
import "../../theme/"
import "../common/"
import "audiomodel.js" as AudioModel

Item {
    id: root

    required property AudioState audio

    readonly property var sink: audio.sink
    readonly property bool muted: !!(sink && sink.audio && sink.audio.muted)
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0

    implicitHeight: Math.max(icon.implicitHeight, labels.implicitHeight, toggle.implicitHeight)

    Text {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: AudioModel.volumeIcon(root.volume, root.muted || !root.sink)
        color: root.sink && !root.muted ? Colors.audio.accent : Colors.audio.muted
        font.family: Style.audio.font.family
        font.pixelSize: Style.audio.hero.iconSize
    }

    Column {
        id: labels
        anchors.left: icon.right
        anchors.leftMargin: Style.audio.hero.gap
        anchors.right: toggle.left
        anchors.rightMargin: Style.audio.hero.gap
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(2)

        Text {
            width: parent.width
            text: root.sink ? AudioModel.deviceLabel(root.sink) : "Audio"
            elide: Text.ElideRight
            color: Colors.audio.text
            font.family: Style.audio.font.family
            font.pixelSize: Style.audio.font.title
            font.bold: true
        }

        Text {
            width: parent.width
            text: {
                if (!root.sink)
                    return "NO OUTPUT";
                return root.muted ? "MUTED" : "OUTPUT · " + AudioModel.percent(root.volume);
            }
            elide: Text.ElideRight
            color: Colors.audio.muted
            font.family: Style.audio.font.family
            font.pixelSize: Style.audio.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }
    }

    Toggle {
        id: toggle
        panelStyle: Style.audio
        panelColors: Colors.audio
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: root.sink !== null
        // On while the output is audible: muting reads as switching sound off.
        checked: !root.muted
        onToggled: root.audio.toggleMute(root.sink)
    }
}
