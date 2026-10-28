// quickshell/panes/notifications/NotificationsPanel.qml
// The notifications panel, centred on the screen like the others: Do Not
// Disturb and the history. Implements the host contract shell.qml expects
// (open/close/opened). NotificationCenter holds everything; the sections
// only draw it. Opening it marks the history read, which clears the bar's
// badge. Two columns (#53): the switch and the history on the left, and on
// the right the notification under the cursor in full, the newest when the
// panel opens. Enter on a notification gives the message the keyboard, for
// its links and actions, until Escape.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../theme/"
import "../../notifications/"

PanelWindow {
    id: root

    property bool opened: false
    visible: opened

    // The notification shown in full: the last one the cursor was on, which
    // stays while it moves to the switch; gone, the newest; null for none.
    property string shownKey: ""
    readonly property var shownRow: {
        var history = NotificationCenter.history;
        return history.find(h => h.key === root.shownKey) || history[0] || null;
    }
    // Whether the message has the keyboard rather than the list.
    property bool messageActive: false

    // The panel takes no payload yet; the argument keeps the host contract.
    function open(payloadJson) {
        opened = true;
    }

    function close() {
        messageActive = false;
        opened = false;
    }

    Cursor {
        id: panelCursor
        onCloseRequested: root.close()
        onMessageRequested: key => {
            root.shownKey = key;
            root.messageActive = true;
        }
        onLineIdChanged: if (panelCursor.keyOf(panelCursor.lineId) !== "")
            root.shownKey = panelCursor.keyOf(panelCursor.lineId)
    }

    // The history emptied while the message had the keys: back to the list.
    onShownRowChanged: if (root.shownRow === null)
        root.messageActive = false

    onOpenedChanged: {
        if (opened) {
            NotificationCenter.markRead();
            clock.now = Date.now();
            root.shownKey = "";
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
        // The message column only when there is a notification to show.
        readonly property real messageWidth: root.shownRow ? Style.notifications.message.width + Style.notifications.card.border + 2 * Style.notifications.card.padding : 0
        implicitWidth: Style.notifications.card.width + messageWidth
        implicitHeight: Math.max(sections.implicitHeight, message.implicitHeight) + 2 * Style.notifications.card.padding

        color: Colors.notifications.background
        radius: Style.notifications.card.radius
        border.width: Style.notifications.card.border
        border.color: Colors.notifications.border

        Keys.onPressed: event => root.messageActive ? message.handleKey(event) : panelCursor.handleKey(event)

        Column {
            id: sections
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: Style.notifications.card.padding
            width: Style.notifications.card.width - 2 * Style.notifications.card.padding
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

        Rectangle {
            id: divider
            visible: root.shownRow !== null
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: sections.right
            anchors.leftMargin: Style.notifications.card.padding
            width: Style.notifications.card.border
            color: Colors.notifications.separator
        }

        Message {
            id: message
            visible: root.shownRow !== null
            anchors.top: parent.top
            anchors.left: divider.right
            anchors.margins: Style.notifications.card.padding
            width: Style.notifications.message.width
            row: root.opened ? root.shownRow : null
            now: clock.now
            active: root.messageActive
            onBackRequested: root.messageActive = false
            onDoneRequested: root.close()
        }
    }
}
