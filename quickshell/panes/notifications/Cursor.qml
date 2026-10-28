// quickshell/panes/notifications/Cursor.qml
// The notifications panel's cursor: a LineCursor whose lines are the Do Not
// Disturb switch, then one per notification in the history. Enter flips the
// switch, or on a notification gives its message the keyboard.
// j and k move like Ctrl+N and Ctrl+P; x forgets the notification under the
// cursor, c forgets them all, d flips Do Not Disturb from anywhere.
import QtQuick
import "../common/"
import "../../notifications/"

LineCursor {
    id: root

    lines: [
        {
            id: "dnd",
            stops: 1
        }
    ].concat(NotificationCenter.history.map(h => ({
                id: "n:" + h.key,
                stops: 1
            })))

    // The history's first notification, else the switch.
    startLine: lines => lines.length > 1 ? 1 : 0

    signal messageRequested(string key)

    function keyOf(line) {
        return line.startsWith("n:") ? line.slice(2) : "";
    }

    onActivated: line => {
        if (line === "dnd")
            NotificationCenter.setDnd(!NotificationCenter.dnd);
        else
            root.messageRequested(root.keyOf(line));
    }

    onOtherKey: event => {
        if (event.modifiers & (Qt.ControlModifier | Qt.AltModifier))
            return;
        var key = event.key;
        if (key === Qt.Key_J || key === Qt.Key_Down)
            root.move(1);
        else if (key === Qt.Key_K || key === Qt.Key_Up)
            root.move(-1);
        else if ((key === Qt.Key_X || key === Qt.Key_Delete) && root.keyOf(root.lineId) !== "")
            NotificationCenter.forget(root.keyOf(root.lineId));
        else if (key === Qt.Key_C) {
            NotificationCenter.dismissAll();
            NotificationCenter.clearHistory();
        } else if (key === Qt.Key_D)
            NotificationCenter.setDnd(!NotificationCenter.dnd);
        else
            return;
        event.accepted = true;
    }
}
