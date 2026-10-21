// quickshell/panes/bluetooth/Cursor.qml
// The Bluetooth panel's cursor: a LineCursor whose lines are the power
// switch, then one per device. On a device BlueZ remembers, the row is
// stop 0 and Forget stop 1. Enter flips the switch, or connects,
// disconnects or pairs the device. j and k move like Ctrl+N and Ctrl+P;
// x forgets, r scans again, b turns Bluetooth on or off.
import QtQuick
import "../common/"
import "btmodel.js" as BtModel

LineCursor {
    id: root

    required property BtState bt

    lines: {
        var result = [];
        if (root.bt.available)
            result.push({
                id: "power",
                stops: 1
            });
        for (var row of root.bt.rows)
            result.push({
                id: "dev:" + row.address,
                stops: BtModel.canForget(row) ? 2 : 1
            });
        return result;
    }

    // On opening: the first device, else the switch.
    startLine: lines => Math.max(0, lines.findIndex(l => l.id.startsWith("dev:")))

    function rowAt(line) {
        return root.bt.rows.find(r => "dev:" + r.address === line) ?? null;
    }

    onActivated: (line, stop) => {
        if (line === "power") {
            root.bt.togglePower();
            return;
        }
        var row = root.rowAt(line);
        if (!row)
            return;
        if (stop === 1)
            root.bt.forget(row);
        else
            root.bt.act(row);
    }

    onOtherKey: event => {
        if (event.modifiers & (Qt.ControlModifier | Qt.AltModifier))
            return;
        var key = event.key;
        var row = root.rowAt(root.lineId);
        if (key === Qt.Key_J || key === Qt.Key_Down)
            root.move(1);
        else if (key === Qt.Key_K || key === Qt.Key_Up)
            root.move(-1);
        else if ((key === Qt.Key_X || key === Qt.Key_Delete) && row)
            root.bt.forget(row);
        else if (key === Qt.Key_R)
            root.bt.rescan();
        else if (key === Qt.Key_B)
            root.bt.togglePower();
        else
            return;
        event.accepted = true;
    }
}
