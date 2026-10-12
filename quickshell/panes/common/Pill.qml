// quickshell/panes/common/Pill.qml
// One choice in a row of choices: filled when it is the one in force,
// ringed when the cursor is on it. It only reports hover and clicks. Its
// looks are the panel's own, passed in, so any panel can use it.
import QtQuick
import "../../theme/"

Rectangle {
    id: root

    required property PanelStyle panelStyle
    required property PanelColors panelColors

    property string text: ""
    property bool active: false
    property bool hasCursor: false

    signal clicked
    signal hovered

    implicitWidth: label.implicitWidth + 2 * root.panelStyle.pill.paddingX
    implicitHeight: label.implicitHeight + 2 * root.panelStyle.pill.paddingY
    radius: root.panelStyle.pill.radius
    color: root.active ? root.panelColors.current : (root.hasCursor ? root.panelColors.hover : "transparent")
    border.width: root.panelStyle.card.border
    border.color: root.hasCursor ? root.panelColors.cursor : (root.active ? root.panelColors.accent : root.panelColors.separator)
    opacity: root.enabled ? 1.0 : 0.5

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.active ? root.panelColors.accent : root.panelColors.text
        font.family: root.panelStyle.font.family
        font.pixelSize: root.panelStyle.font.body
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
