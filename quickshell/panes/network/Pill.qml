// quickshell/panes/network/Pill.qml
// One choice in a row of choices: filled when it is the one in force,
// ringed when the cursor is on it. It only reports hover and clicks.
import QtQuick
import "../../theme/"

Rectangle {
    id: root

    property string text: ""
    property bool active: false
    property bool hasCursor: false

    signal clicked
    signal hovered

    implicitWidth: label.implicitWidth + 2 * Style.network.pill.paddingX
    implicitHeight: label.implicitHeight + 2 * Style.network.pill.paddingY
    radius: Style.network.pill.radius
    color: root.active ? Colors.network.current : (root.hasCursor ? Colors.network.hover : "transparent")
    border.width: Style.network.card.border
    border.color: root.hasCursor ? Colors.network.cursor : (root.active ? Colors.network.accent : Colors.network.separator)
    opacity: root.enabled ? 1.0 : 0.5

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.active ? Colors.network.accent : Colors.network.text
        font.family: Style.network.font.family
        font.pixelSize: Style.network.font.body
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered()
        onClicked: root.clicked()
    }
}
