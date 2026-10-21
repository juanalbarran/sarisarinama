// quickshell/bar/widgets/Bell.qml
// Notifications: a bell, with a badge while there are ones the panel has not
// shown, crossed out under Do Not Disturb. Hidden unless the shell is the
// notification daemon. A click asks for the panel, a right click flips Do
// Not Disturb, as a right click on the speaker mutes.
import QtQuick
import "../../theme/"
import "../../notifications/"

Text {
    id: root

    signal clicked

    visible: NotificationCenter.enabled
    text: NotificationCenter.dnd ? "\u{f009b}" : NotificationCenter.unread > 0 ? "\u{f116b}" : "\u{f009a}"
    color: mouse.containsMouse ? Colors.bar.hover : NotificationCenter.unread > 0 && !NotificationCenter.dnd ? Colors.bar.focused : Colors.bar.text
    font.family: Style.bar.font.family
    font.pixelSize: Style.bar.textSize("bell", "body")

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: event => {
            if (event.button === Qt.RightButton)
                NotificationCenter.setDnd(!NotificationCenter.dnd);
            else
                root.clicked();
        }
    }
}
