// quickshell/panes/common/LineCursor.qml
// A panel's one highlight, and the keys that move it. A panel is a stack
// of lines and a line has one or more stops (a pill each on a row of
// pills, a row and its buttons on a list row). Ctrl+N and Ctrl+P, or
// Down and Up, move between lines, wrapping round as in the menu; h and l
// move between stops; Enter activates the stop; Escape asks to close.
// The mouse moves the same cursor, so there is never a second highlight.
// A line is named, not numbered, so the cursor stays on its row when a
// list is re-sorted around it.
//
// A panel extends this: it binds `lines`, and says what Enter does by
// handling `activated`.
import QtQuick

QtObject {
    id: root

    // [{id, stops}], top to bottom.
    property var lines: []
    // While true the keys belong to someone else, a text field say, and
    // Ctrl+N or Ctrl+P must not move the line out from under it.
    property bool blocked: false
    // Down and Up move between lines as Ctrl+N and Ctrl+P do; false leaves
    // them to otherKey, for a panel that scrolls with them.
    property bool arrows: true
    // The line the cursor starts on when the panel opens, as an index.
    property var startLine: lines => 0
    // The stop it lands on when Ctrl+N or Ctrl+P arrive on a line.
    property var firstStop: id => 0

    signal activated(string line, int stop)
    signal closeRequested
    // A key the cursor does not use, for the panel's own shortcuts. The
    // handler sets event.accepted to keep it.
    signal otherKey(var event)

    property string lineId: ""
    property int stop: 0
    // Where the cursor was, for when its line leaves the panel.
    property int lastIndex: 0

    // The position of a line. Computed on every call rather than kept in a
    // binding: inside onLinesChanged, a binding over `lines` may not have
    // caught up yet, and would hand back the old position.
    function find(id) {
        return lines.findIndex(l => l.id === id);
    }

    function at(id, s) {
        return lineId === id && stop === s;
    }

    // Puts the cursor on a stop by name: what hovering does.
    function select(id, s) {
        var i = find(id);
        if (i >= 0)
            place(i, s);
    }

    function place(i, s) {
        lastIndex = i;
        lineId = lines[i].id;
        stop = Math.max(0, Math.min(s, lines[i].stops - 1));
    }

    // What opening the panel does.
    function reset() {
        lineId = "";
        stop = 0;
        if (lines.length === 0)
            return;
        place(Math.max(0, Math.min(startLine(lines), lines.length - 1)), 0);
    }

    // Keeps the cursor on a line that exists: when its line leaves the
    // panel, it lands on the line that took its place.
    function settle() {
        var i = find(lineId);
        if (lines.length === 0) {
            lineId = "";
            stop = 0;
        } else if (lineId === "") {
            reset();
        } else if (i < 0) {
            place(Math.min(lastIndex, lines.length - 1), 0);
        } else {
            place(i, stop);
        }
    }

    onLinesChanged: settle()

    function move(dy) {
        var n = lines.length;
        if (n === 0)
            return;
        var i = find(lineId);
        var from = i < 0 ? 0 : i;
        var to = ((from + dy) % n + n) % n;
        place(to, firstStop(lines[to].id));
    }

    function moveStop(dx) {
        var i = find(lineId);
        if (i >= 0)
            place(i, stop + dx);
    }

    function activate() {
        if (find(lineId) >= 0)
            activated(lineId, stop);
    }

    // Returns without accepting a key it does not use, so the key can go on
    // to whatever else wants it.
    function handleKey(event) {
        if (blocked)
            return;
        var ctrl = (event.modifiers & Qt.ControlModifier) !== 0;
        var key = event.key;
        if ((ctrl && key === Qt.Key_N) || (arrows && key === Qt.Key_Down))
            move(1);
        else if ((ctrl && key === Qt.Key_P) || (arrows && key === Qt.Key_Up))
            move(-1);
        else if (ctrl)
            return;
        else if (key === Qt.Key_H)
            moveStop(-1);
        else if (key === Qt.Key_L)
            moveStop(1);
        else if (key === Qt.Key_Return || key === Qt.Key_Enter)
            activate();
        else if (key === Qt.Key_Escape)
            closeRequested();
        else {
            otherKey(event);
            return;
        }
        event.accepted = true;
    }
}
