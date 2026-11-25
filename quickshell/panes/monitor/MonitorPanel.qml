// quickshell/panes/monitor/MonitorPanel.qml
// The monitor panel window, centred on the screen like the others.
// Implements the host contract shell.qml expects (open/close/opened).
// MonState holds what the compositor says; the sections only draw it.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../theme/"
import "../../compositor/"
import "../common/"

PanelWindow {
    id: root

    property bool opened: false
    visible: opened

    // The panel takes no payload yet; the argument keeps the host contract.
    function open(payloadJson) {
        // On the focused display, named, so the panel knows when it goes.
        root.screen = Quickshell.screens.find(s => s.name === Compositor.focusedOutput) ?? null;
        opened = true;
    }

    // Turning off the display the panel is on takes its window with it.
    // Closed here too, or the panel would stay open with nothing on screen
    // and the next summon would close it instead of showing it.
    Connections {
        target: Quickshell
        function onScreensChanged() {
            if (root.opened && Quickshell.screens.indexOf(root.screen) < 0)
                root.close();
        }
    }

    function close() {
        opened = false;
    }

    MonState {
        id: monState
        active: root.opened
    }

    Cursor {
        id: panelCursor
        mon: monState
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
    WlrLayershell.namespace: "sarisarinama-monitor"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
        id: card
        anchors.fill: parent
        implicitWidth: Style.monitor.card.width
        implicitHeight: sections.implicitHeight + 2 * Style.monitor.card.padding

        color: Colors.monitor.background
        radius: Style.monitor.card.radius
        border.width: Style.monitor.card.border
        border.color: Colors.monitor.border

        Keys.onPressed: event => panelCursor.handleKey(event)

        Column {
            id: sections
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Style.monitor.card.padding
            spacing: Style.monitor.gap

            Hero {
                width: parent.width
                mon: monState
            }

            Rectangle {
                width: parent.width
                height: Style.monitor.card.border
                color: Colors.monitor.separator
            }

            DisplayList {
                width: parent.width
                mon: monState
                cursor: panelCursor
            }

            Rectangle {
                width: parent.width
                height: Style.monitor.card.border
                visible: scaleRow.visible
                color: Colors.monitor.separator
            }

            PillRow {
                id: scaleRow
                panelStyle: Style.monitor
                panelColors: Colors.monitor
                width: parent.width
                visible: monState.target !== null
                cursor: panelCursor
                lineId: "scale"
                // Named only when there is more than one display to choose from.
                title: monState.target && monState.activeCount > 1 ? "SCALE · " + monState.target.name : "SCALE"
                options: monState.scales.map(s => ({
                            id: s,
                            label: s + "×"
                        }))
                current: monState.currentScale
                onPicked: id => monState.setScale(id)
            }
        }
    }
}
