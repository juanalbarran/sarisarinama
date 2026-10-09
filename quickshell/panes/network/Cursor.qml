// quickshell/panes/network/Cursor.qml
// The panel's one highlight, and the keys that move it. The panel is a
// stack of lines (the Wi-Fi switch, the band and DNS rows, then one per
// network) and a line has one or more stops (a pill each on the band and
// DNS rows; on a saved network, the row and then Forget). Ctrl+N and
// Ctrl+P move between lines, h and l between stops, Enter acts on the
// stop. The mouse moves the same cursor, so there is never a second
// highlight. A line is named, not numbered, so the cursor stays on its
// network when the list is re-sorted around it.
import QtQuick
import "netmodel.js" as NetModel

QtObject {
    id: root

    required property NetState net
    // Whether the network list is on screen; its rows are lines only then.
    property bool listShown: false
    // The band and DNS rows, and whether each is on screen.
    property NetSettings settings: null
    property bool bandShown: false
    property bool dnsShown: false

    signal closeRequested

    property string lineId: ""
    property int stop: 0
    // Where the cursor was, for when its line leaves the panel.
    property int lastIndex: 0

    // [{id, stops}], top to bottom.
    readonly property var lines: {
        var result = [];
        if (net.canToggleWifi)
            result.push({
                id: "toggle",
                stops: 1
            });
        if (settings && bandShown)
            result.push({
                id: "band",
                stops: settings.bandOptions.length
            });
        if (settings && dnsShown)
            result.push({
                id: "dns",
                stops: settings.providers.length
            });
        if (listShown)
            for (var row of net.rows)
                result.push({
                    id: "wifi:" + row.ssid,
                    stops: NetModel.canForget(row) ? 2 : 1
                });
        return result;
    }

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

    // On opening: the first network, which is the connected one when there
    // is one; the switch when there is no list.
    function reset() {
        lineId = "";
        stop = 0;
        if (lines.length === 0)
            return;
        var i = lines.findIndex(l => l.id.startsWith("wifi:"));
        place(i >= 0 ? i : 0, 0);
    }

    // Keeps the cursor on a line that exists: when its network leaves the
    // list, it lands on the line that took its place.
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

    // Up and down wrap round, as in the menu: down from the last network
    // goes back to the switch.
    function move(dy) {
        var n = lines.length;
        if (n === 0)
            return;
        var i = find(lineId);
        var from = i < 0 ? 0 : i;
        var to = ((from + dy) % n + n) % n;
        place(to, firstStop(lines[to].id));
    }

    // Arriving on the band or DNS row lands on the choice in force, so
    // Enter there changes nothing until h or l moves away from it.
    function firstStop(id) {
        if (id === "band")
            return Math.max(0, settings.bandOptions.indexOf(settings.bandSelected));
        if (id === "dns")
            return Math.max(0, settings.providers.findIndex(p => p.name === settings.dnsSelected));
        return 0;
    }

    function moveStop(dx) {
        var i = find(lineId);
        if (i >= 0)
            place(i, stop + dx);
    }

    function activate() {
        if (lineId === "toggle") {
            net.toggleWifi();
            return;
        }
        if (lineId === "band") {
            settings.setBand(settings.bandOptions[stop]);
            return;
        }
        if (lineId === "dns") {
            settings.setDns(settings.providers[stop].name);
            return;
        }
        var row = net.rows.find(r => "wifi:" + r.ssid === lineId);
        if (!row)
            return;
        if (stop === 1)
            net.forget(row);
        else
            net.activate(row);
    }

    // Returns without accepting a key it does not use, so the key can go on
    // to whatever else wants it. While the password prompt is open the
    // prompt has the keyboard, and Ctrl+N or Ctrl+P must not move the row
    // out from under it.
    function handleKey(event) {
        if (net.passwordSsid !== "")
            return;
        var ctrl = (event.modifiers & Qt.ControlModifier) !== 0;
        var key = event.key;
        if (ctrl && key === Qt.Key_N)
            move(1);
        else if (ctrl && key === Qt.Key_P)
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
        else if (key === Qt.Key_R)
            net.rescan();
        else if (key === Qt.Key_W)
            net.toggleWifi();
        else
            return;
        event.accepted = true;
    }
}
