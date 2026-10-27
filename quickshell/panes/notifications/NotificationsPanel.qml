// quickshell/panes/notifications/NotificationsPanel.qml
// The notifications panel, centred on the screen like the others: Do Not
// Disturb and the history. Implements the host contract shell.qml expects
// (open/close/opened). NotificationCenter holds everything; the sections
// only draw it. Opening it marks the history read, which clears the bar's
// badge. A notification clicked, or picked with Enter, opens in full in a
// MessagePanel over this one, which takes the keyboard until Escape.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../theme/"
import "../../notifications/"

PanelWindow {
    id: root

    property bool opened: false
    visible: opened

    // The notification open in full, "" for none.
    property string messageKey: ""
    readonly property var messageRow: {
        var key = root.messageKey;
        return key === "" ? null : NotificationCenter.history.find(h => h.key === key) || null;
    }

    // The panel takes no payload yet; the argument keeps the host contract.
    function open(payloadJson) {
        opened = true;
    }

    function close() {
        messageKey = "";
        opened = false;
    }

    Cursor {
        id: panelCursor
        onCloseRequested: root.close()
        onMessageRequested: key => root.messageKey = key
    }

    MessagePanel {
        screen: root.screen
        row: root.opened ? root.messageRow : null
        now: clock.now
        onBackRequested: {
            root.messageKey = "";
            card.forceActiveFocus();
        }
        onDoneRequested: root.close()
    }

    // A notification forgotten while open in full: back to the list.
    onMessageRowChanged: if (root.messageKey !== "" && root.messageRow === null)
        root.messageKey = ""

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
    // The message over it takes the keyboard while it is open.
    WlrLayershell.keyboardFocus: opened && messageKey === "" ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

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
