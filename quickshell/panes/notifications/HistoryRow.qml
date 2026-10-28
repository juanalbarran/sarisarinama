// quickshell/panes/notifications/HistoryRow.qml
// One notification in the history: its icon, the app and when, the summary
// and the first lines of the body. A dot marks one still on screen. A click
// puts the cursor on it, which shows it in full beside the list; a middle
// click forgets it. Hovering does not move the cursor, or crossing the list
// on the way to the message would swap the message under the pointer.
import QtQuick
import "../../theme/"
import "../common/"
import "../../notifications/"
import "../../notifications/notifmodel.js" as NotifModel

Rectangle {
    id: root

    required property var row
    required property Cursor cursor
    // The panel's clock, so "5m" moves on while the panel is open.
    property real now: Date.now()

    readonly property string line: "n:" + root.row.key
    readonly property bool current: root.cursor.at(root.line, 0)
    readonly property bool onScreen: {
        NotificationCenter.toasts.count;
        return NotificationCenter.isShown(root.row.key);
    }

    implicitHeight: Math.max(noticeIcon.height, text.implicitHeight) + 2 * Style.notifications.row.paddingY
    radius: Style.notifications.row.radius
    color: root.current ? Colors.notifications.current : "transparent"

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton)
                NotificationCenter.forget(root.row.key);
            else
                root.cursor.select(root.line, 0);
        }
    }

    NoticeIcon {
        id: noticeIcon
        anchors.left: parent.left
        anchors.leftMargin: Style.notifications.row.paddingX
        anchors.top: parent.top
        anchors.topMargin: Style.notifications.row.paddingY
        row: root.row
        size: Style.notifications.history.iconSize
        radius: Style.notifications.row.radius
        tile: root.row.urgency === NotifModel.CRITICAL ? Colors.notifications.urgent : Colors.notifications.accent
        letterColor: Colors.notifications.background
        fontFamily: Style.notifications.font.family
    }

    Column {
        id: text
        anchors.left: noticeIcon.right
        anchors.leftMargin: Style.notifications.row.gap
        anchors.right: parent.right
        anchors.rightMargin: Style.notifications.row.paddingX
        anchors.top: parent.top
        anchors.topMargin: Style.notifications.row.paddingY
        spacing: Style.space(2)

        Item {
            width: parent.width
            implicitHeight: Math.max(app.implicitHeight, when.implicitHeight)

            Text {
                id: app
                anchors.left: parent.left
                anchors.right: when.left
                anchors.rightMargin: Style.space(6)
                text: root.row.app.toUpperCase()
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: Colors.notifications.muted
                font.family: Style.notifications.font.family
                font.pixelSize: Style.notifications.font.caption
                font.bold: true
                font.letterSpacing: 1.2
            }

            Text {
                id: when
                anchors.right: parent.right
                text: (root.onScreen ? "● " : "") + NotifModel.ago(root.row.ts, root.now)
                color: root.onScreen ? Colors.notifications.accent : Colors.notifications.muted
                font.family: Style.notifications.font.family
                font.pixelSize: Style.notifications.font.caption
            }
        }

        Text {
            width: parent.width
            visible: root.row.summary !== ""
            text: root.row.summary
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: root.row.urgency === NotifModel.CRITICAL ? Colors.notifications.urgent : Colors.notifications.text
            font.family: Style.notifications.font.family
            font.pixelSize: Style.notifications.font.body
            font.bold: true
        }

        Text {
            width: parent.width
            visible: root.row.body !== ""
            text: root.row.body
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            color: Colors.notifications.muted
            font.family: Style.notifications.font.family
            font.pixelSize: Style.notifications.font.caption
        }
    }
}
