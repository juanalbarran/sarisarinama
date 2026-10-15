// quickshell/panes/vpn/Hero.qml
// The top row of the panel: the VPN icon, the connected profile and the
// state. Everything it shows is read from VpnState.
import QtQuick
import "../../theme/"
import "vpnmodel.js" as VpnModel

Item {
    id: root

    required property VpnState vpn

    implicitHeight: Math.max(icon.implicitHeight, labels.implicitHeight)

    Text {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: VpnModel.icon()
        color: root.vpn.connected ? Colors.vpn.accent : Colors.vpn.muted
        font.family: Style.vpn.font.family
        font.pixelSize: Style.vpn.hero.iconSize
    }

    Column {
        id: labels
        anchors.left: icon.right
        anchors.leftMargin: Style.vpn.hero.gap
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(2)

        Text {
            width: parent.width
            text: root.vpn.connected ? root.vpn.connected.name : "VPN"
            elide: Text.ElideRight
            color: Colors.vpn.text
            font.family: Style.vpn.font.family
            font.pixelSize: Style.vpn.font.title
            font.bold: true
        }

        Text {
            width: parent.width
            text: {
                if (root.vpn.connected)
                    return "CONNECTED · " + VpnModel.typeLabel(root.vpn.connected).toUpperCase();
                if (root.vpn.busy && root.vpn.busyUp)
                    return "CONNECTING…";
                if (root.vpn.profiles.length === 0)
                    return "NO VPN PROFILES";
                return "NOT CONNECTED";
            }
            elide: Text.ElideRight
            color: Colors.vpn.muted
            font.family: Style.vpn.font.family
            font.pixelSize: Style.vpn.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }
    }
}
