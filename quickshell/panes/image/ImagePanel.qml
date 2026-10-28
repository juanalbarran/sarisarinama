// quickshell/panes/image/ImagePanel.qml
// The image viewer: the whole screen dimmed, the image fitted in it, and a
// caption under it. Implements the host contract shell.qml expects
// (open/close/opened); the payload names the file, {"path": "<file>"}, and
// sarisarinama-image sends it, so xdg-open lands here. Omarchy opens images
// in imv; this keeps them in the shell, in the shell's colours.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../theme/"

PanelWindow {
    id: root

    property bool opened: false
    visible: opened

    function open(payloadJson) {
        var payload = {};
        try {
            payload = JSON.parse(payloadJson || "{}");
        } catch (e) {}
        // Without a path the viewer shows what it showed last.
        if (payload.path)
            images.show(payload.path);
        viewport.reset();
        opened = true;
    }

    function close() {
        opened = false;
    }

    ImageState {
        id: images
    }

    // The viewer's keys; the backdrop holds the keyboard while it is open.
    // Lowercase h and l step through the folder, uppercase pan. An
    // uppercase letter is the text typed or Shift with the key: a keymap
    // may send either without the other.
    function handleKey(event) {
        var key = event.key;
        var shift = (event.modifiers & Qt.ShiftModifier) !== 0;
        var typed = shift && event.text.length === 1 ? event.text.toUpperCase() : event.text;
        var nudge = Style.image.pan;
        if (key === Qt.Key_Escape || typed === "q") {
            close();
        } else if (typed === "H") {
            viewport.pan(nudge, 0);
        } else if (typed === "L") {
            viewport.pan(-nudge, 0);
        } else if (typed === "K") {
            viewport.pan(0, nudge);
        } else if (typed === "J") {
            viewport.pan(0, -nudge);
        } else if (typed === "l" || typed === "n" || key === Qt.Key_Right || key === Qt.Key_Space) {
            images.move(1);
        } else if (typed === "h" || typed === "p" || key === Qt.Key_Left || key === Qt.Key_Backspace) {
            images.move(-1);
        } else if (typed === "g" || key === Qt.Key_Home) {
            images.first();
        } else if (typed === "G" || key === Qt.Key_End) {
            images.last();
        } else if (typed === "+" || typed === "=") {
            viewport.zoomBy(Style.image.zoom.step);
        } else if (typed === "-") {
            viewport.zoomBy(1 / Style.image.zoom.step);
        } else if (typed === "0") {
            viewport.reset();
        } else if (typed === "1") {
            viewport.actualSize();
        } else if (typed === "i") {
            caption.hints = !caption.hints;
        } else {
            return;
        }
        event.accepted = true;
    }

    onOpenedChanged: if (opened)
        backdrop.forceActiveFocus()

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sarisarinama-image"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Colors.image.backdrop

        focus: true
        Keys.onPressed: event => root.handleKey(event)

        Viewport {
            id: viewport
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: caption.top
            anchors.margins: Style.image.margin
            images: images
        }

        Caption {
            id: caption
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.image.margin
            images: images
            viewport: viewport
        }
    }
}
