// quickshell/panes/notifications/NotificationsPanel.qml
// The notifications panel, centred on the screen like the others: Do Not
// Disturb and the history. Implements the host contract shell.qml expects
// (open/close/opened). NotificationCenter holds everything; the sections
// only draw it. Opening it marks the history read, which clears the bar's
// badge.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../theme/"
import "../../notifications/"

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

    Cursor {
        id: panelCursor
        onCloseRequested: root.close()
    }

    onOpenedChanged: {
        if (opened) {
            NotificationCenter.markRead();
            clock.now = Date.now();
            panelCursor.reset();
            card.forceActiveFocus();
        }
    }

    // What arrives while the panel is open is read already.
    Connections {
        target: NotificationCenter
        enabled: root.opened
        function onUnreadChanged() {
            if (NotificationCenter.unread > 0)
                NotificationCenter.markRead();
        }
    }

    Timer {
        id: clock
        property real now: Date.now()
        interval: 30000
        repeat: true
        running: root.opened
        onTriggered: now = Date.now()
    }

    // No anchors: a layer-shell window anchored to no edge is centred by
    // the compositor, on Sway and Hyprland alike.
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sarisarinama-notifications-panel"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
        id: card
        anchors.fill: parent
        implicitWidth: Style.notifications.card.width
        implicitHeight: sections.implicitHeight + 2 * Style.notifications.card.padding

        color: Colors.notifications.background
        radius: Style.notifications.card.radius
        border.width: Style.notifications.card.border
        border.color: Colors.notifications.border

        Keys.onPressed: event => panelCursor.handleKey(event)

        Column {
            id: sections
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Style.notifications.card.padding
            spacing: Style.notifications.gap

            Hero {
                width: parent.width
                cursor: panelCursor
            }

            Rectangle {
                width: parent.width
                height: Style.notifications.card.border
                color: Colors.notifications.separator
            }

            HistoryList {
                width: parent.width
                cursor: panelCursor
                now: clock.now
            }
        }
    }
}
