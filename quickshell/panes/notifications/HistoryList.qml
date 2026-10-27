// quickshell/panes/notifications/HistoryList.qml
// The history, newest first, scrolling past style.notifications.history
// .maxHeight and following the cursor; a hint when it is empty.
import QtQuick
import "../../theme/"
import "../common/"
import "../../notifications/"

Item {
    id: root

    required property Cursor cursor
    property real now: Date.now()

    readonly property bool empty: NotificationCenter.history.length === 0

    implicitHeight: root.empty ? hint.implicitHeight : body.height

    Flickable {
        id: body
        width: parent.width
        height: Math.min(contentHeight, Style.notifications.history.maxHeight)
        visible: !root.empty
        contentWidth: width
        contentHeight: rows.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Column {
            id: rows
            width: body.width
            spacing: Style.notifications.list.spacing

            Repeater {
                id: repeater
                model: NotificationCenter.history

                HistoryRow {
                    required property var modelData

                    width: rows.width
                    row: modelData
                    cursor: root.cursor
                    now: root.now
                }
            }
        }
    }

    // Scrolls just enough to bring the cursor's row into view.
    function follow() {
        var key = root.cursor.lineId.startsWith("n:") ? root.cursor.lineId.slice(2) : "";
        if (key === "") {
            body.contentY = 0;
            return;
        }
        for (var i = 0; i < repeater.count; i++) {
            var item = repeater.itemAt(i);
            if (!item || item.row.key !== key)
                continue;
            if (item.y < body.contentY)
                body.contentY = item.y;
            else if (item.y + item.height > body.contentY + body.height)
                body.contentY = item.y + item.height - body.height;
            return;
        }
    }

    Connections {
        target: root.cursor
        function onLineIdChanged() {
            Qt.callLater(root.follow);
        }
    }

    // A thin bar on the right edge, only when there is more to see.
    Rectangle {
        visible: body.visible && body.contentHeight > body.height
        anchors.right: parent.right
        width: Style.space(3)
        radius: width / 2
        y: body.visibleArea.yPosition * body.height
        height: body.visibleArea.heightRatio * body.height
        color: Colors.notifications.track
    }

    Text {
        id: hint
        width: parent.width
        visible: root.empty
        topPadding: Style.space(12)
        bottomPadding: Style.space(12)
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        text: NotificationCenter.enabled ? "Nothing yet" : "Not the notification daemon: set programs.sarisarinama.notifications.enable"
        color: Colors.notifications.muted
        font.family: Style.notifications.font.family
        font.pixelSize: Style.notifications.font.body
    }
}
