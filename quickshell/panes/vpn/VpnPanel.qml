// quickshell/panes/vpn/VpnPanel.qml
// The VPN panel window, centred on the screen like the others.
// Implements the host contract shell.qml expects (open/close/opened).
// VpnState holds what NetworkManager says; the sections only draw it.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../theme/"

PanelWindow {
    id: root

    property bool opened: false
    visible: opened

    // The panel takes no payload yet; the argument keeps the host contract.
    function open(payloadJson) {
        opened = true;
    }

    function close() {
        opened = false;
    }

    VpnState {
        id: vpnState
        active: root.opened
    }

    Cursor {
        id: panelCursor
        vpn: vpnState
        onCloseRequested: root.close()
    }

    onOpenedChanged: {
        if (opened) {
            panelCursor.reset();
            card.forceActiveFocus();
        }
    }

    // No anchors: a layer-shell window anchored to no edge is centred by
    // the compositor, on Sway and Hyprland alike.
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sarisarinama-vpn"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
        id: card
        anchors.fill: parent
        implicitWidth: Style.vpn.card.width
        implicitHeight: sections.implicitHeight + 2 * Style.vpn.card.padding

        color: Colors.vpn.background
        radius: Style.vpn.card.radius
        border.width: Style.vpn.card.border
        border.color: Colors.vpn.border

        Keys.onPressed: event => panelCursor.handleKey(event)

        Column {
            id: sections
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Style.vpn.card.padding
            spacing: Style.vpn.gap

            Hero {
                width: parent.width
                vpn: vpnState
            }

            Rectangle {
                width: parent.width
                height: Style.vpn.card.border
                color: Colors.vpn.separator
            }

            VpnList {
                width: parent.width
                vpn: vpnState
                cursor: panelCursor
            }
        }
    }
}
