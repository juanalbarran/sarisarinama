// quickshell/panes/battery/BatteryPanel.qml
// The battery panel window, centred on the screen like the others.
// Implements the host contract shell.qml expects (open/close/opened).
// BatteryState holds what UPower says; the sections only draw it.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../theme/"
import "../common/"

PanelWindow {
    id: root

    property bool opened: false
    visible: opened

    // The panel takes no payload yet; the argument keeps the host contract.
    // A machine with no battery has nothing to show, so it does not open.
    function open(payloadJson) {
        if (batteryState.present)
            opened = true;
    }

    function close() {
        opened = false;
    }

    BatteryState {
        id: batteryState
        // Unplugging a USB battery, say: nothing left to show.
        onPresentChanged: if (!present)
            root.close()
    }

    Cursor {
        id: panelCursor
        battery: batteryState
        onCloseRequested: root.close()
    }

    onOpenedChanged: {
        if (opened) {
            panelCursor.reset();
            // reset() lands on the first pill; start on the one in force.
            panelCursor.select("profile", panelCursor.firstStop("profile"));
            card.forceActiveFocus();
        }
    }

    // No anchors: a layer-shell window anchored to no edge is centred by
    // the compositor, on Sway and Hyprland alike.
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sarisarinama-battery"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
        id: card
        anchors.fill: parent
        implicitWidth: Style.battery.card.width
        implicitHeight: sections.implicitHeight + 2 * Style.battery.card.padding

        color: Colors.battery.background
        radius: Style.battery.card.radius
        border.width: Style.battery.card.border
        border.color: Colors.battery.border

        Keys.onPressed: event => panelCursor.handleKey(event)

        Column {
            id: sections
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Style.battery.card.padding
            spacing: Style.battery.gap

            Hero {
                width: parent.width
                battery: batteryState
            }

            ChargeBar {
                width: parent.width
                battery: batteryState
            }

            Stats {
                width: parent.width
                battery: batteryState
            }

            Rectangle {
                width: parent.width
                height: Style.battery.card.border
                color: Colors.battery.separator
            }

            PillRow {
                width: parent.width
                panelStyle: Style.battery
                panelColors: Colors.battery
                cursor: panelCursor
                lineId: "profile"
                title: batteryState.degraded ? "POWER PROFILE · LIMITED: " + batteryState.degraded.toUpperCase() : "POWER PROFILE"
                failed: batteryState.degraded !== ""
                options: batteryState.profiles
                current: batteryState.profile
                onPicked: id => batteryState.setProfile(id)
            }
        }
    }
}
