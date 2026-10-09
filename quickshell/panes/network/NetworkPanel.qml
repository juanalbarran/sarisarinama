// quickshell/panes/network/NetworkPanel.qml
// The network panel window, centred on the screen like the menu.
// Implements the host contract shell.qml expects (open/close/opened).
// NetState holds what NetworkManager says; the sections only draw it.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../theme/"
import "settingsmodel.js" as SettingsModel

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

    NetState {
        id: netState
        active: root.opened
    }

    // No anchors: a layer-shell window anchored to no edge is centred by
    // the compositor, on Sway and Hyprland alike.
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sarisarinama-network"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    NetStats {
        id: netStats
        active: root.opened
    }

    NetSettings {
        id: netSettings
        active: root.opened
    }

    Cursor {
        id: panelCursor
        net: netState
        settings: netSettings
        bandShown: bandRow.visible
        dnsShown: dnsRow.visible
        listShown: wifiList.visible
        onCloseRequested: root.close()
    }

    onOpenedChanged: {
        if (opened) {
            panelCursor.reset();
            card.forceActiveFocus();
        }
    }

    // A closed password prompt hands the keyboard back, so Escape closes
    // the panel again.
    Connections {
        target: netState
        function onPasswordSsidChanged() {
            if (netState.passwordSsid === "")
                card.forceActiveFocus();
        }
    }

    Rectangle {
        id: card
        anchors.fill: parent
        implicitWidth: Style.network.card.width
        implicitHeight: sections.implicitHeight + 2 * Style.network.card.padding

        color: Colors.network.background
        radius: Style.network.card.radius
        border.width: Style.network.card.border
        border.color: Colors.network.border

        Keys.onPressed: event => panelCursor.handleKey(event)

        Column {
            id: sections
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Style.network.card.padding
            spacing: Style.network.gap

            Hero {
                width: parent.width
                net: netState
                cursor: panelCursor
            }

            Stats {
                width: parent.width
                stats: netStats
            }

            Rectangle {
                width: parent.width
                height: Style.network.card.border
                visible: bandRow.visible || dnsRow.visible
                color: Colors.network.separator
            }

            PillRow {
                id: bandRow
                width: parent.width
                visible: netSettings.bandShown
                cursor: panelCursor
                lineId: "band"
                title: {
                    if (netSettings.errorRow === "band")
                        return netSettings.error.toUpperCase();
                    if (netSettings.changing === "band")
                        return "WI-FI BAND · RECONNECTING…";
                    return netSettings.band.band ? "WI-FI BAND · ON " + netSettings.band.band + " GHZ" : "WI-FI BAND";
                }
                failed: netSettings.errorRow === "band"
                options: netSettings.bandOptions.map(b => ({
                            id: b,
                            label: SettingsModel.bandLabel(b)
                        }))
                current: netSettings.bandSelected
                busy: netSettings.changing !== ""
                onPicked: id => netSettings.setBand(id)
            }

            PillRow {
                id: dnsRow
                width: parent.width
                visible: netSettings.dnsShown
                cursor: panelCursor
                lineId: "dns"
                title: {
                    if (netSettings.errorRow === "dns")
                        return netSettings.error.toUpperCase();
                    if (netSettings.changing === "dns")
                        return "DNS · APPLYING…";
                    // Servers that match no provider are named outright.
                    if (netSettings.dnsSelected === "" && netSettings.dns.servers)
                        return "DNS · " + netSettings.dns.servers.join(", ");
                    return "DNS";
                }
                failed: netSettings.errorRow === "dns"
                options: netSettings.providers.map(p => ({
                            id: p.name,
                            label: p.name
                        }))
                current: netSettings.dnsSelected
                busy: netSettings.changing !== ""
                onPicked: id => netSettings.setDns(id)
            }

            Rectangle {
                width: parent.width
                height: Style.network.card.border
                visible: wifiList.visible
                color: Colors.network.separator
            }

            WifiList {
                id: wifiList
                width: parent.width
                net: netState
                cursor: panelCursor
            }
        }
    }
}
