// quickshell/panes/notifications/MessagePanel.qml
// One notification in full, over the notifications panel: the whole
// summary and body, nothing cut, the body's addresses as links. Below it a
// row of its links, and while it is still on screen a row of its actions,
// the default one as "Open". The cursor starts on the actions, so Enter
// twice from the list runs "Open"; with none it starts on the links. The notifications panel owns it: `row` says
// which, and Escape hands the keyboard back to the list. Following a link
// or running an action asks for everything to close.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../theme/"
import "../common/"
import "../../notifications/"
import "../../notifications/notifmodel.js" as NotifModel

PanelWindow {
    id: root

    // A history row, or null when no message is open.
    property var row: null
    property real now: Date.now()

    signal backRequested
    signal doneRequested

    visible: root.row !== null

    readonly property var links: {
        try {
            return JSON.parse(root.row ? root.row.links || "[]" : "[]");
        } catch (e) {
            return [];
        }
    }
    readonly property bool onScreen: {
        NotificationCenter.toasts.count;
        return root.row !== null && NotificationCenter.isShown(root.row.key);
    }
    // Only a notification still on screen can still be acted on.
    readonly property var actions: {
        if (!root.onScreen)
            return [];
        var out = root.row.hasDefault ? [
            {
                id: "default",
                label: "Open"
            }
        ] : [];
        try {
            JSON.parse(root.row.actions || "[]").forEach(a => out.push({
                    id: a.id,
                    label: a.text
                }));
        } catch (e) {}
        return out;
    }

    function follow(href) {
        Qt.openUrlExternally(href);
        root.doneRequested();
    }

    function invoke(id) {
        NotificationCenter.invoke(root.row.key, id);
        root.doneRequested();
    }

    LineCursor {
        id: messageCursor
        lines: (root.links.length > 0 ? [
                {
                    id: "links",
                    stops: root.links.length
                }
            ] : []).concat(root.actions.length > 0 ? [
            {
                id: "actions",
                stops: root.actions.length
            }
        ] : [])
        startLine: lines => Math.max(0, lines.findIndex(l => l.id === "actions"))
        onCloseRequested: root.backRequested()
        onActivated: (line, stop) => {
            if (line === "links")
                root.follow(root.links[stop]);
            else if (line === "actions")
                root.invoke(root.actions[stop].id);
        }
        // j and k scroll the message, as in the keybinds pane.
        onOtherKey: event => {
            if (event.modifiers & (Qt.ControlModifier | Qt.AltModifier))
                return;
            var step = Style.notifications.font.body * 3;
            if (event.key === Qt.Key_J || event.key === Qt.Key_Down)
                body.scrollBy(step);
            else if (event.key === Qt.Key_K || event.key === Qt.Key_Up)
                body.scrollBy(-step);
            else
                return;
            event.accepted = true;
        }
    }

    // The reset waits for the lines, which follow the row a moment later.
    onRowChanged: {
        body.contentY = 0;
        Qt.callLater(messageCursor.reset);
        if (root.row)
            card.forceActiveFocus();
    }

    // Centred like the panel under it, so it reads as a page laid over it.
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sarisarinama-notification-message"
    WlrLayershell.keyboardFocus: root.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
        id: card
        anchors.fill: parent
        implicitWidth: Style.notifications.card.width
        implicitHeight: sections.implicitHeight + 2 * Style.notifications.card.padding

        color: Colors.notifications.background
        radius: Style.notifications.card.radius
        border.width: Style.notifications.card.border
        border.color: root.row && root.row.urgency === NotifModel.CRITICAL ? Colors.notifications.urgent : Colors.notifications.border

        Keys.onPressed: event => messageCursor.handleKey(event)

        Column {
            id: sections
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Style.notifications.card.padding
            spacing: Style.notifications.gap

            Row {
                width: parent.width
                spacing: Style.notifications.row.gap

                NoticeIcon {
                    id: noticeIcon
                    row: root.row || {}
                    size: Style.notifications.toast.iconSize
                    radius: Style.notifications.row.radius
                    tile: root.row && root.row.urgency === NotifModel.CRITICAL ? Colors.notifications.urgent : Colors.notifications.accent
                    letterColor: Colors.notifications.background
                    fontFamily: Style.notifications.font.family
                }

                Column {
                    width: parent.width - noticeIcon.width - parent.spacing
                    spacing: Style.space(2)

                    Text {
                        width: parent.width
                        text: root.row ? root.row.app.toUpperCase() + "  ·  " + NotifModel.ago(root.row.ts, root.now) : ""
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: Colors.notifications.muted
                        font.family: Style.notifications.font.family
                        font.pixelSize: Style.notifications.font.caption
                        font.bold: true
                        font.letterSpacing: 1.2
                    }

                    Text {
                        width: parent.width
                        visible: text !== ""
                        text: root.row ? root.row.summary : ""
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        color: root.row && root.row.urgency === NotifModel.CRITICAL ? Colors.notifications.urgent : Colors.notifications.text
                        font.family: Style.notifications.font.family
                        font.pixelSize: Style.notifications.font.title
                        font.bold: true
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: Style.notifications.card.border
                color: Colors.notifications.separator
            }

            // The whole body; past history.maxHeight it scrolls.
            Item {
                width: parent.width
                implicitHeight: body.height

                Flickable {
                    id: body
                    width: parent.width
                    height: Math.min(contentHeight, Style.notifications.history.maxHeight)
                    contentWidth: width
                    contentHeight: bodyText.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true

                    function scrollBy(dy) {
                        contentY = Math.max(0, Math.min(contentHeight - height, contentY + dy));
                    }

                    Text {
                        id: bodyText
                        width: body.width - Style.space(8)
                        text: root.row && root.row.body !== "" ? NotifModel.linkified(root.row.body) : "No message"
                        textFormat: Text.StyledText
                        wrapMode: Text.Wrap
                        color: root.row && root.row.body !== "" ? Colors.notifications.text : Colors.notifications.muted
                        linkColor: Colors.notifications.accent
                        font.family: Style.notifications.font.family
                        font.pixelSize: Style.notifications.font.body
                        onLinkActivated: link => root.follow(link)

                        // Text takes link clicks but sets no pointer shape.
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            cursorShape: bodyText.hoveredLink !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                }

                Rectangle {
                    visible: body.contentHeight > body.height
                    anchors.right: parent.right
                    width: Style.space(3)
                    radius: width / 2
                    y: body.visibleArea.yPosition * body.height
                    height: body.visibleArea.heightRatio * body.height
                    color: Colors.notifications.track
                }
            }

            PillRow {
                width: parent.width
                visible: root.links.length > 0
                panelStyle: Style.notifications
                panelColors: Colors.notifications
                cursor: messageCursor
                lineId: "links"
                title: root.links.length === 1 ? "LINK" : "LINKS"
                options: root.links.map(l => ({
                            id: l,
                            label: NotifModel.linkLabel(l, 40)
                        }))
                onPicked: id => root.follow(id)
            }

            PillRow {
                width: parent.width
                visible: root.actions.length > 0
                panelStyle: Style.notifications
                panelColors: Colors.notifications
                cursor: messageCursor
                lineId: "actions"
                title: "ACTIONS"
                options: root.actions
                onPicked: id => root.invoke(id)
            }
        }
    }
}
