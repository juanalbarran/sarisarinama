// quickshell/panes/vpn/VpnList.qml
// Every VPN profile NetworkManager knows, the connected ones first. A
// machine has a handful at most, so the list never scrolls. With none,
// it says how to add one.
import QtQuick
import "../../theme/"

Column {
    id: root

    required property VpnState vpn
    required property Cursor cursor

    spacing: Style.vpn.list.spacing

    Text {
        text: "PROFILES"
        color: Colors.vpn.muted
        font.family: Style.vpn.font.family
        font.pixelSize: Style.vpn.font.caption
        font.bold: true
        font.letterSpacing: 1.2
    }

    Text {
        width: root.width
        visible: root.vpn.profiles.length === 0
        text: "Import one with nmcli connection import"
        wrapMode: Text.Wrap
        color: Colors.vpn.muted
        font.family: Style.vpn.font.family
        font.pixelSize: Style.vpn.font.body
    }

    Repeater {
        model: root.vpn.profiles

        VpnRow {
            required property var modelData

            width: root.width
            profile: modelData
            vpn: root.vpn
            cursor: root.cursor
        }
    }
}
