// quickshell/panes/keybinds/KeybindsPanel.qml
// The keybinds pane, centred on the screen like the panels. Implements the
// host contract shell.qml expects (open/close/opened); the payload names
// the section to show, {"section": "<id>"}, and without one the pane
// shows the section it showed last. Typing filters; there is nothing to
// select, so Ctrl+N and Ctrl+P scroll instead of moving a cursor.
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
        if (payload.section)
            keyState.sectionId = payload.section;
        keyState.query = "";
        body.contentY = 0;
        opened = true;
    }

    function close() {
        opened = false;
    }

    KeybindsState {
        id: keyState
    }

    function scroll(dy) {
        var bottom = Math.max(0, body.contentHeight - body.height);
        body.contentY = Math.max(0, Math.min(body.contentY + dy, bottom));
    }

    // The pane's keys, offered by the filter box before it takes the text.
    // Leaves the rest unaccepted, so they are typed.
    function handleKey(event) {
        var ctrl = (event.modifiers & Qt.ControlModifier) !== 0;
        var shift = (event.modifiers & Qt.ShiftModifier) !== 0;
        var key = event.key;
        var line = Style.keybinds.font.body * 2;
        if (key === Qt.Key_Escape) {
            if (keyState.query !== "")
                keyState.query = "";
            else
                close();
        } else if (key === Qt.Key_Tab && !shift) {
            keyState.cycle(1);
            body.contentY = 0;
        } else if (key === Qt.Key_Backtab || key === Qt.Key_Tab) {
            // Shift+Tab arrives as Backtab or as Tab with Shift, depending
            // on the keymap.
            keyState.cycle(-1);
            body.contentY = 0;
        } else if ((ctrl && key === Qt.Key_N) || key === Qt.Key_Down) {
            scroll(line * 3);
        } else if ((ctrl && key === Qt.Key_P) || key === Qt.Key_Up) {
            scroll(-line * 3);
        } else if ((ctrl && key === Qt.Key_D) || key === Qt.Key_PageDown) {
            scroll(body.height / 2);
        } else if ((ctrl && key === Qt.Key_U) || key === Qt.Key_PageUp) {
            scroll(-body.height / 2);
        } else {
            return;
        }
        event.accepted = true;
    }

    onOpenedChanged: if (opened)
        filter.focusInput()

    // No anchors: a layer-shell window anchored to no edge is centred by
    // the compositor, on Sway and Hyprland alike.
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sarisarinama-keybinds"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Everything but the binds, so the binds get what is left of the
    // screen share without a binding through their own height.
    readonly property int chrome: header.implicitHeight + filter.implicitHeight + separator.height + hints.implicitHeight + 4 * Style.keybinds.gap + 2 * Style.keybinds.card.padding
    readonly property int maxBody: Math.max(Style.keybinds.font.body * 4, Math.round((root.screen?.height ?? 1080) * Style.keybinds.maxHeight) - chrome)

    Rectangle {
        id: card
        anchors.fill: parent
        implicitWidth: Style.keybinds.card.width
        implicitHeight: content.implicitHeight + 2 * Style.keybinds.card.padding

        color: Colors.keybinds.background
        radius: Style.keybinds.card.radius
        border.width: Style.keybinds.card.border
        border.color: Colors.keybinds.border

        Column {
            id: content
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Style.keybinds.card.padding
            spacing: Style.keybinds.gap

            Header {
                id: header
                width: parent.width
                keys: keyState
                onPicked: id => {
                    keyState.sectionId = id;
                    body.contentY = 0;
                    filter.focusInput();
                }
            }

            Filter {
                id: filter
                width: parent.width
                keys: keyState
                panel: root
            }

            Rectangle {
                id: separator
                width: parent.width
                height: Style.keybinds.card.border
                color: Colors.keybinds.separator
            }

            Item {
                width: parent.width
                height: keyState.shown > 0 ? body.height : empty.implicitHeight

                Flickable {
                    id: body
                    width: parent.width
                    height: Math.min(contentHeight, root.maxBody)
                    visible: keyState.shown > 0
                    contentWidth: width
                    contentHeight: columns.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true

                    Columns {
                        id: columns
                        width: body.width
                        keys: keyState
                    }
                }

                // A thin bar on the right edge, only when there is more to see.
                Rectangle {
                    visible: body.visible && body.contentHeight > body.height
                    anchors.right: parent.right
                    width: Style.space(3)
                    radius: width / 2
                    y: body.visibleArea.yPosition * body.height
                    height: body.visibleArea.heightRatio * body.height
                    color: Colors.keybinds.track
                }

                Text {
                    id: empty
                    width: parent.width
                    visible: keyState.shown === 0
                    topPadding: Style.space(12)
                    bottomPadding: Style.space(12)
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: keyState.section ? "Nothing matches “" + keyState.query.trim() + "”" : "No keybinds yet: set programs.sarisarinama.keybinds"
                    color: Colors.keybinds.muted
                    font.family: Style.keybinds.font.family
                    font.pixelSize: Style.keybinds.font.body
                }
            }

            Hints {
                id: hints
                anchors.horizontalCenter: parent.horizontalCenter
                tabs: keyState.sections.length > 1
            }
        }
    }
}
