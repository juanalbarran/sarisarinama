// quickshell/panes/bluetooth/BluetoothPanel.qml
// The Bluetooth panel window, centred on the screen like the others: the
// power switch and the devices, connected, paired, and what a scan finds
// while it is open. Implements the host contract shell.qml expects
// (open/close/opened). BtState holds what BlueZ says; the sections only
// draw it. After omarchy quattro's bluetooth panel.
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

    BtState {
        id: btState
        active: root.opened
    }

    Cursor {
        id: panelCursor
        bt: btState
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
    WlrLayershell.namespace: "sarisarinama-bluetooth"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
        id: card
        anchors.fill: parent
        implicitWidth: Style.bluetooth.card.width
        implicitHeight: sections.implicitHeight + 2 * Style.bluetooth.card.padding

        color: Colors.bluetooth.background
        radius: Style.bluetooth.card.radius
        border.width: Style.bluetooth.card.border
        border.color: Colors.bluetooth.border

        Keys.onPressed: event => panelCursor.handleKey(event)

        Column {
            id: sections
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Style.bluetooth.card.padding
            spacing: Style.bluetooth.gap

            Hero {
                width: parent.width
                bt: btState
                cursor: panelCursor
            }

            Rectangle {
                width: parent.width
                height: Style.bluetooth.card.border
                color: Colors.bluetooth.separator
            }

            DeviceList {
                width: parent.width
                bt: btState
                cursor: panelCursor
            }
        }
    }
}
