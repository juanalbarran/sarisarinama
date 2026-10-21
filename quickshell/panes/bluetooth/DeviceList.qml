// quickshell/panes/bluetooth/DeviceList.qml
// The devices under their headings, scrolling past list.maxHeight and
// following the cursor; a hint when there is nothing to list.
import QtQuick
import "../../theme/"

Item {
    id: root

    required property BtState bt
    required property Cursor cursor

    readonly property bool empty: root.bt.rows.length === 0

    implicitHeight: root.empty ? hint.implicitHeight : body.height

    Flickable {
        id: body
        width: parent.width
        height: Math.min(contentHeight, Style.bluetooth.list.maxHeight)
        visible: !root.empty
        contentWidth: width
        contentHeight: rows.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Column {
            id: rows
            width: body.width
            spacing: Style.bluetooth.list.spacing

            Repeater {
                id: repeater
                model: root.bt.rows

                DeviceRow {
                    width: rows.width
                    bt: root.bt
                    cursor: root.cursor
                }
            }
        }
    }

    // Scrolls just enough to bring the cursor's row into view.
    function follow() {
        for (var i = 0; i < repeater.count; i++) {
            var item = repeater.itemAt(i);
            if (!item || item.lineId !== root.cursor.lineId)
                continue;
            if (item.y < body.contentY)
                body.contentY = item.y;
            else if (item.y + item.height > body.contentY + body.height)
                body.contentY = item.y + item.height - body.height;
            return;
        }
        body.contentY = 0;
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
        color: Colors.bluetooth.track
    }

    Text {
        id: hint
        width: parent.width
        visible: root.empty
        topPadding: Style.space(12)
        bottomPadding: Style.space(12)
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        text: {
            if (!root.bt.available)
                return "No Bluetooth adapter";
            if (root.bt.hardBlocked)
                return "Bluetooth is off by a hardware switch";
            if (!root.bt.on)
                return "Turn Bluetooth on to see devices";
            return "Scanning for devices…";
        }
        color: Colors.bluetooth.muted
        font.family: Style.bluetooth.font.family
        font.pixelSize: Style.bluetooth.font.body
    }
}
