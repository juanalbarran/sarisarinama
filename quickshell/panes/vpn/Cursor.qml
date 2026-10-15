// quickshell/panes/vpn/Cursor.qml
// The VPN panel's cursor: a LineCursor with one line per profile. Enter
// brings the profile under it up or down. Beyond the shared keys, r reads
// the profiles again.
import QtQuick
import "../common/"

LineCursor {
    id: root

    required property VpnState vpn

    lines: root.vpn.profiles.map(p => ({
                id: "vpn:" + p.uuid,
                stops: 1
            }))

    // The default startLine, 0, is the first profile: the connected one
    // when there is one, since the list puts it first.

    onActivated: (line, stop) => root.vpn.toggle(line.slice("vpn:".length))

    onOtherKey: event => {
        if (event.key !== Qt.Key_R)
            return;
        root.vpn.refresh();
        event.accepted = true;
    }
}
