// quickshell/bar/widgets/Audio.qml
import Quickshell.Services.Pipewire
import QtQuick
import "../../theme/"

Text {
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real vol: sink?.audio.volume ?? 0

    PwObjectTracker {
        objects: [sink]
    }

    text: sink?.audio.muted ? "\udb81\udf5f" : vol > 0.66 ? "\uf028" : vol > 0.33 ? "\uf027" : "\uf026"
    color: mouse.containsMouse ? Colors.hover : Colors.text
    font.family: Style.font.family
    font.pixelSize: Style.bar.textSize("audio", "body")

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: sink.audio.muted = !sink.audio.muted
        onWheel: wheel => {
            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + step));
        }
    }
}
