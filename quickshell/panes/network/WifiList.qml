// quickshell/panes/network/WifiList.qml
// The nearby networks, known ones first, scrolling once they pass
// list.maxHeight. Shown only while there is a Wi-Fi radio and it is on.
import QtQuick
import "../../theme/"

Column {
    id: root

    required property NetState net
    required property Cursor cursor

    visible: net.wifiDevice !== null && net.wifiEnabled
    spacing: Style.network.list.spacing

    // A fresh scan takes a few seconds; until then the list is empty.
    Text {
        visible: list.count === 0
        text: "SCANNING…"
        color: Colors.network.muted
        font.family: Style.network.font.family
        font.pixelSize: Style.network.font.caption
        font.bold: true
        font.letterSpacing: 1.2
    }

    ListView {
        id: list
        width: parent.width
        height: Math.min(contentHeight, Style.network.list.maxHeight)
        visible: count > 0
        clip: true
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds
        spacing: Style.network.list.spacing

        model: root.net.rows

        delegate: WifiRow {
            width: ListView.view.width
            net: root.net
            cursor: root.cursor
        }

        // Scrolls just far enough to keep the cursor's row in view.
        Connections {
            target: root.cursor
            function onLineIdChanged() {
                var i = root.net.rows.findIndex(r => "wifi:" + r.ssid === root.cursor.lineId);
                if (i >= 0)
                    list.positionViewAtIndex(i, ListView.Contain);
            }
        }
    }
}
