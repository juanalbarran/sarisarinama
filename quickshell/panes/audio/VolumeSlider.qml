// quickshell/panes/audio/VolumeSlider.qml
// A volume as a slider: a track, a fill as far as the volume and a knob at
// its end. Press or drag anywhere on it. It only reports where the pointer
// is; whoever owns `value` sets the volume, so the knob never shows a
// level PipeWire did not take.
import QtQuick
import "../../theme/"

Item {
    id: root

    property real value: 0
    property bool muted: false
    property bool hasCursor: false

    signal moved(real value)
    signal hovered

    // PipeWire allows a boost past 100%; the slider stops at its end.
    readonly property real shown: Math.max(0, Math.min(1, value))
    readonly property color fillColor: root.muted ? Colors.audio.muted : Colors.audio.accent

    implicitHeight: knob.height

    function at(x) {
        return Math.max(0, Math.min(1, (x - knob.width / 2) / Math.max(1, width - knob.width)));
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: Style.audio.slider.height
        radius: height / 2
        color: Colors.audio.track
    }

    Rectangle {
        anchors.left: track.left
        anchors.verticalCenter: track.verticalCenter
        width: knob.x + knob.width / 2
        height: track.height
        radius: track.radius
        color: root.fillColor
    }

    Rectangle {
        id: knob
        width: Style.audio.slider.knob
        height: width
        radius: width / 2
        x: root.shown * (root.width - width)
        anchors.verticalCenter: parent.verticalCenter
        color: root.fillColor
        border.width: root.hasCursor ? Style.audio.card.border : 0
        border.color: Colors.audio.cursor
    }

    // The cursor ring, round the whole slider, as Toggle draws its own.
    Rectangle {
        anchors.fill: parent
        anchors.margins: -Style.space(4)
        radius: height / 2
        color: "transparent"
        border.width: Style.audio.card.border
        border.color: Colors.audio.cursor
        visible: root.hasCursor
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered()
        onPressed: mouse => root.moved(root.at(mouse.x))
        onPositionChanged: mouse => {
            if (pressed)
                root.moved(root.at(mouse.x));
        }
    }
}
