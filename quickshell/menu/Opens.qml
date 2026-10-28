// quickshell/menu/Opens.qml
// What the remembered menus opened, oldest first, one JSON line each:
// {"menu": <file>, "row": <key>}. Kept in the state dir, so it outlives a
// logout, and only the last `keep` lines stay, so old habits fade. The
// shell is the only writer, so the lines in memory are the file.
import Quickshell
import Quickshell.Io

FileView {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property int keep: 1000
    property var lines: []

    path: (Quickshell.env("XDG_STATE_HOME") || root.home + "/.local/state") + "/sarisarinama/menus-opened"
    // Read before the first menu opens; missing until something is opened
    blockLoading: true
    printErrors: false

    onLoaded: {
        var out = [];
        text().split("\n").forEach(line => {
            try {
                var record = JSON.parse(line);
                if (record && typeof record.menu === "string" && typeof record.row === "string")
                    out.push(record);
            } catch (e) {}
        });
        root.lines = out.slice(-root.keep);
    }

    // A row that opens a submenu, spelled the same from the row and from
    // the trail of menus walked, where the path is already expanded
    function menuKey(path, arg) {
        var p = String(path).indexOf("~") === 0 ? root.home + String(path).slice(1) : String(path);
        return "menu " + p + (arg ? "\t" + arg : "");
    }

    // A row may carry its own `key`, for an action that changes when
    // nothing the user picked did: a theme's names the store path
    function key(row) {
        if (row.key)
            return String(row.key);
        if (row.app)
            return "app " + row.app.id;
        if (row.menu)
            return root.menuKey(row.menu, row.arg);
        return "action " + row.action;
    }

    function add(records) {
        root.lines = root.lines.concat(records).slice(-root.keep);
        root.setText(root.lines.map(r => JSON.stringify(r)).join("\n") + "\n");
    }

    // Most opened first; ties go to the one opened last, then to the order
    // the rows came in
    function order(menuPath, rows) {
        var uses = {};
        var last = {};
        root.lines.forEach((r, i) => {
            if (r.menu !== menuPath)
                return;
            uses[r.row] = (uses[r.row] || 0) + 1;
            last[r.row] = i;
        });
        return rows.map((row, i) => {
            var k = root.key(row);
            return {
                row: row,
                order: i,
                uses: uses[k] || 0,
                last: k in last ? last[k] : -1
            };
        }).sort((a, b) => b.uses - a.uses || b.last - a.last || a.order - b.order).map(o => o.row);
    }
}
