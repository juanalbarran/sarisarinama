// quickshell/panes/monitor/Cursor.qml
// The monitor panel's cursor: a LineCursor whose lines are one per
// display, then the scale row. Enter on a display turns it on or off;
// on the scale row it applies the scale under the cursor. Beyond the
// shared keys, r reads the displays again.
import QtQuick
import "../common/"

LineCursor {
    id: root

    required property MonState mon

    lines: {
        var result = root.mon.outputs.map(o => ({
                    id: "out:" + o.name,
                    stops: 1
                }));
        if (root.mon.target && root.mon.scales.length > 0)
            result.push({
                id: "scale",
                stops: root.mon.scales.length
            });
        return result;
    }

    // On opening: the display the scale row acts on.
    startLine: lines => root.mon.target ? Math.max(0, lines.findIndex(l => l.id === "out:" + root.mon.target.name)) : 0

    // Arriving on the scale row lands on the scale in force.
    firstStop: id => id === "scale" ? Math.max(0, root.mon.scales.indexOf(root.mon.currentScale)) : 0

    onActivated: (line, stop) => {
        if (line === "scale")
            root.mon.setScale(root.mon.scales[stop]);
        else
            root.mon.toggle(line.slice("out:".length));
    }

    onOtherKey: event => {
        if (event.key !== Qt.Key_R)
            return;
        root.mon.refresh();
        event.accepted = true;
    }
}
