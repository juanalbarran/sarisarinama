// quickshell/panes/network/Toggle.qml
// An on/off switch: a pill with a knob that slides across. It only reports
// the click; whoever owns `checked` decides what the click does, so the
// switch never shows a state NetworkManager did not confirm.
import QtQuick
import "../../theme/"

Rectangle {
    id: root

    property bool checked: false
    property bool hasCursor: false

    signal toggled
    signal hovered

    readonly property int inset: Style.space(2)

    implicitWidth: Style.network.toggle.width
    implicitHeight: Style.network.toggle.height
    radius: height / 2
    color: root.checked ? Colors.network.accent : Colors.network.track

    Rectangle {
        width: root.height - 2 * root.inset
        height: width
        radius: width / 2
        y: root.inset
        x: root.checked ? root.width - width - root.inset : root.inset
        color: root.checked ? Colors.network.background : Colors.network.text

        Behavior on x {
            NumberAnimation {
                duration: Style.network.toggle.animation
            }
        }
    }

    // The cursor ring, drawn just outside the pill so it shows whether
    // the switch is on or off.
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2 * root.inset
        radius: height / 2
        color: "transparent"
        border.width: Style.network.card.border
        border.color: Colors.network.cursor
        visible: root.hasCursor
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered()
        onClicked: root.toggled()
    }
}
