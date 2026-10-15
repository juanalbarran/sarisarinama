// quickshell/panes/vpn/VpnRow.qml
// One profile: its icon, its name, its type and state, or the error of
// the last change, and on the right its switch. Enter, or a click on the
// switch, brings it up or down. While a change runs, every switch is
// greyed out: VpnState makes one change at a time.
import QtQuick
import "../../theme/"
import "../common/"
import "vpnmodel.js" as VpnModel

Rectangle {
    id: root

    required property var profile
    required property VpnState vpn
    required property Cursor cursor

    readonly property string lineId: "vpn:" + profile.uuid
    readonly property bool selected: cursor.at(lineId, 0)
    readonly property bool connected: profile.state === "activated"
    readonly property bool changing: vpn.busyUuid === profile.uuid
    readonly property bool failed: vpn.errorUuid === profile.uuid

    implicitHeight: Math.max(icon.implicitHeight, labels.implicitHeight, toggle.implicitHeight) + 2 * Style.vpn.row.paddingY
    radius: Style.vpn.row.radius
    color: root.selected ? Colors.vpn.hover : (root.connected ? Colors.vpn.current : "transparent")

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.cursor.select(root.lineId, 0)
    }

    Text {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: Style.vpn.row.paddingX
        anchors.verticalCenter: parent.verticalCenter
        text: VpnModel.icon()
        color: root.connected ? Colors.vpn.text : Colors.vpn.muted
        font.family: Style.vpn.font.family
        font.pixelSize: Style.vpn.font.title
    }

    Column {
        id: labels
        anchors.left: icon.right
        anchors.leftMargin: Style.vpn.row.gap
        anchors.right: toggle.left
        anchors.rightMargin: Style.vpn.row.gap
        anchors.verticalCenter: parent.verticalCenter

        Text {
            width: parent.width
            text: root.profile.name
            elide: Text.ElideRight
            color: root.connected ? Colors.vpn.text : Colors.vpn.muted
            font.family: Style.vpn.font.family
            font.pixelSize: Style.vpn.font.body
        }

        Text {
            width: parent.width
            text: {
                if (root.failed)
                    return root.vpn.error;
                if (root.changing)
                    return root.vpn.busyUp ? "Connecting…" : "Disconnecting…";
                return VpnModel.typeLabel(root.profile) + (root.connected ? " · Connected" : "");
            }
            elide: Text.ElideRight
            color: root.failed ? Colors.vpn.urgent : Colors.vpn.muted
            font.family: Style.vpn.font.family
            font.pixelSize: Style.vpn.font.caption
        }
    }

    Toggle {
        id: toggle
        panelStyle: Style.vpn
        panelColors: Colors.vpn
        anchors.right: parent.right
        anchors.rightMargin: Style.vpn.row.paddingX
        anchors.verticalCenter: parent.verticalCenter
        // During a change it shows where the change is going, not where
        // NetworkManager still is.
        checked: root.changing ? root.vpn.busyUp : VpnModel.isUp(root.profile)
        enabled: !root.vpn.busy
        opacity: enabled ? 1.0 : 0.5
        hasCursor: root.selected
        onToggled: root.vpn.toggle(root.profile.uuid)
        onHovered: root.cursor.select(root.lineId, 0)
    }
}
