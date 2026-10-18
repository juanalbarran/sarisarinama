// quickshell/panes/audio/AudioPanel.qml
// The audio panel window, centred on the screen like the others.
// Implements the host contract shell.qml expects (open/close/opened).
// AudioState holds what PipeWire says; the sections only draw it.
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

    AudioState {
        id: audioState
        active: root.opened
    }

    Cursor {
        id: panelCursor
        audio: audioState
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
    WlrLayershell.namespace: "sarisarinama-audio"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
        id: card
        anchors.fill: parent
        implicitWidth: Style.audio.card.width
        implicitHeight: sections.implicitHeight + 2 * Style.audio.card.padding

        color: Colors.audio.background
        radius: Style.audio.card.radius
        border.width: Style.audio.card.border
        border.color: Colors.audio.border

        Keys.onPressed: event => {
            if (!panelCursor.slide(event))
                panelCursor.handleKey(event);
        }

        Column {
            id: sections
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Style.audio.card.padding
            spacing: Style.audio.gap

            Hero {
                width: parent.width
                audio: audioState
            }

            Rectangle {
                width: parent.width
                height: Style.audio.card.border
                color: Colors.audio.separator
            }

            DeviceSection {
                width: parent.width
                audio: audioState
                cursor: panelCursor
                kind: "out"
            }

            DeviceSection {
                width: parent.width
                audio: audioState
                cursor: panelCursor
                kind: "in"
            }

            Rectangle {
                width: parent.width
                height: Style.audio.card.border
                color: Colors.audio.separator
            }

            AppList {
                width: parent.width
                audio: audioState
                cursor: panelCursor
            }
        }
    }
}
