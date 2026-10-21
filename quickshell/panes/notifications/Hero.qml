// quickshell/panes/notifications/Hero.qml
// The top row of the panel: the bell, how many notifications the history
// holds (or that Do Not Disturb is on, or that the shell is not the daemon),
// and on the right the Do Not Disturb switch.
import QtQuick
import "../../theme/"
import "../common/"
import "../../notifications/"

Item {
    id: root

    required property LineCursor cursor

    implicitHeight: Math.max(icon.implicitHeight, labels.implicitHeight, toggle.implicitHeight)

    Text {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: NotificationCenter.dnd ? "󰂛" : "󰂚"
        color: NotificationCenter.dnd ? Colors.notifications.muted : Colors.notifications.accent
        font.family: Style.notifications.font.family
        font.pixelSize: Style.notifications.hero.iconSize
    }

    Column {
        id: labels
        anchors.left: icon.right
        anchors.leftMargin: Style.notifications.hero.gap
        anchors.right: toggle.left
        anchors.rightMargin: Style.notifications.hero.gap
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(2)

        Text {
            width: parent.width
            text: "Notifications"
            elide: Text.ElideRight
            color: Colors.notifications.text
            font.family: Style.notifications.font.family
            font.pixelSize: Style.notifications.font.title
            font.bold: true
        }

        Text {
            width: parent.width
            text: {
                if (!NotificationCenter.enabled)
                    return "OFF: SET NOTIFICATIONS.ENABLE";
                var n = NotificationCenter.history.length;
                var count = n + (n === 1 ? " NOTIFICATION" : " NOTIFICATIONS");
                return NotificationCenter.dnd ? "DO NOT DISTURB · " + count : count;
            }
            elide: Text.ElideRight
            color: NotificationCenter.dnd ? Colors.notifications.accent : Colors.notifications.muted
            font.family: Style.notifications.font.family
            font.pixelSize: Style.notifications.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }
    }

    Toggle {
        id: toggle
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        panelStyle: Style.notifications
        panelColors: Colors.notifications
        checked: NotificationCenter.dnd
        hasCursor: root.cursor.at("dnd", 0)
        onToggled: NotificationCenter.setDnd(!NotificationCenter.dnd)
        onHovered: root.cursor.select("dnd", 0)
    }
}
