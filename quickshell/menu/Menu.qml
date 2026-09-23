// quickshell/menu/Menu.qml
// The menu window. Implements the host contract shell.qml expects
// (open/close/opened); Model owns navigation, Card owns the look and the
// size: the window is exactly as large as the card asks to be.
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property bool opened: false
    visible: opened

    // Payload is {"file": "<menu json>"}; no file means the root menu.
    function open(payloadJson) {
        var payload = {};
        try {
            payload = JSON.parse(payloadJson || "{}");
        } catch (e) {}
        model.navStack = [];
        model.show(payload.file || "");
        opened = true;
    }

    function close() {
        opened = false;
    }

    Model {
        id: model
    }

    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sarisarinama-menu"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onOpenedChanged: if (opened)
        card.focusList()

    Card {
        id: card
        anchors.fill: parent
        menu: model
        // A card that swallows the screen reads as a page, not a menu.
        maxHeight: Math.round((root.screen?.height ?? 1080) * 0.7)
        onCloseRequested: root.close()
    }
}
