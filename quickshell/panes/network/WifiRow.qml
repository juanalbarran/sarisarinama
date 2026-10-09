// quickshell/panes/network/WifiRow.qml
// One network in the list: its signal, its name and what is happening to
// it, and on the right a lock (needs a password) or Forget (saved). A click
// connects or disconnects; NetState decides which, and whether a password
// is needed first, in which case Passphrase opens under the row.
import QtQuick
import "../../theme/"
import "netmodel.js" as NetModel

Column {
    id: root

    // Set by the ListView: the row's plain values and its position.
    required property var modelData
    required property int index
    required property NetState net
    required property Cursor cursor

    readonly property var row: modelData
    readonly property string lineId: "wifi:" + row.ssid
    readonly property bool selected: cursor.at(lineId, 0)
    readonly property bool forgetSelected: cursor.at(lineId, 1)
    readonly property bool busy: net.busy && net.actionSsid === row.ssid
    readonly property bool failed: net.failure !== "" && net.failedSsid === row.ssid
    readonly property bool asking: net.passwordSsid === row.ssid
    readonly property bool forgettable: NetModel.canForget(row)
    // A saved network shows Forget at once; a locked one shows its lock
    // until the cursor is on it, so the two never sit side by side.
    readonly property bool showForget: forgettable && (!row.secured || forgetSelected)

    readonly property string status: {
        if (busy)
            return ({
                    connect: "Connecting…",
                    disconnect: "Disconnecting…",
                    forget: "Forgetting…"
                })[net.actionKind];
        if (failed)
            return net.failure;
        if (row.connected)
            return net.portal ? "Sign-in required" : "Connected";
        return "";
    }

    spacing: Style.network.list.spacing

    Text {
        visible: root.row.heading !== ""
        topPadding: root.index > 0 ? Style.network.gap : 0
        text: root.row.heading
        color: Colors.network.muted
        font.family: Style.network.font.family
        font.pixelSize: Style.network.font.caption
        font.bold: true
        font.letterSpacing: 1.2
    }

    Rectangle {
        width: parent.width
        implicitHeight: Math.max(icon.implicitHeight, labels.implicitHeight) + 2 * Style.network.row.paddingY
        radius: Style.network.row.radius
        color: root.selected && !root.net.busy ? Colors.network.hover : (root.row.connected ? Colors.network.current : "transparent")

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: !root.net.busy
            cursorShape: Qt.PointingHandCursor
            onEntered: root.cursor.select(root.lineId, 0)
            onClicked: root.net.activate(root.row)
        }

        Text {
            id: icon
            anchors.left: parent.left
            anchors.leftMargin: Style.network.row.paddingX
            anchors.verticalCenter: parent.verticalCenter
            text: NetModel.icon("wifi", root.row.signal, root.row.connected && root.net.restricted)
            color: root.failed ? Colors.network.urgent : Colors.network.text
            font.family: Style.network.font.family
            font.pixelSize: Style.network.font.title
        }

        Column {
            id: labels
            anchors.left: icon.right
            anchors.leftMargin: Style.network.row.gap
            anchors.right: side.visible ? side.left : parent.right
            anchors.rightMargin: side.visible ? Style.network.row.gap : Style.network.row.paddingX
            anchors.verticalCenter: parent.verticalCenter

            Text {
                width: parent.width
                text: root.row.ssid
                elide: Text.ElideRight
                color: Colors.network.text
                font.family: Style.network.font.family
                font.pixelSize: Style.network.font.body
            }

            Text {
                width: parent.width
                visible: root.status !== ""
                text: root.status
                elide: Text.ElideRight
                color: root.failed ? Colors.network.urgent : Colors.network.muted
                font.family: Style.network.font.family
                font.pixelSize: Style.network.font.caption
            }
        }

        Text {
            id: side
            anchors.right: parent.right
            anchors.rightMargin: Style.network.row.paddingX
            anchors.verticalCenter: parent.verticalCenter
            visible: root.row.secured || root.forgettable
            text: root.showForget ? "󰅙" : "󰌾"
            color: root.showForget ? Colors.network.urgent : Colors.network.muted
            font.family: Style.network.font.family
            font.pixelSize: Style.network.font.title

            // The cursor on Forget; z -1 draws it behind the glyph.
            Rectangle {
                z: -1
                anchors.centerIn: parent
                width: parent.width + 2 * Style.network.row.paddingY
                height: width
                radius: Style.network.row.radius
                color: Colors.network.hover
                visible: root.forgetSelected && !root.net.busy
            }

            // Declared after rowMouse, so it sits on top and takes the click.
            MouseArea {
                id: sideMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: root.forgettable && !root.net.busy
                cursorShape: Qt.PointingHandCursor
                onEntered: root.cursor.select(root.lineId, 1)
                onClicked: root.net.forget(root.row)
            }
        }
    }

    // Created only while asked for, so it can take the keyboard as it opens.
    Loader {
        width: parent.width
        active: root.asking
        visible: active
        sourceComponent: Passphrase {
            net: root.net
            ssid: root.row.ssid
        }
    }
}
