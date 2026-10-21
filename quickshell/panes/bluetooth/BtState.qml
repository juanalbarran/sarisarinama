// quickshell/panes/bluetooth/BtState.qml
// What BlueZ says, read live through Quickshell.Bluetooth, and the actions
// the panel takes. Reads are bindings over BlueZ's own objects, so the panel
// follows a change the moment it happens. Actions run the
// sarisarinama-bluetooth-* scripts, one at a time, after omarchy: they go
// through bluetoothctl and rfkill rather than BlueZ's D-Bus calls, see
// docs/bluetooth.md. The panel's sections read from here; none of them
// talks to BlueZ.
import QtQuick
import Quickshell.Bluetooth
import Quickshell.Io
import "btmodel.js" as BtModel

QtObject {
    id: root

    // True while the panel is open. Only then does the adapter scan: a scan
    // costs power and slows connections, and nothing shows it while closed.
    property bool active: false

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: root.adapter !== null
    readonly property bool on: root.available && root.adapter.enabled
    // The adapter's switch, held in the hard rfkill position (a key on the
    // laptop): nothing here can turn it on.
    readonly property bool hardBlocked: root.available && root.adapter.state === BluetoothAdapterState.Blocked && !root.on
    readonly property bool discovering: root.on && root.adapter.discovering

    // A string first, so an update that changes nothing emits nothing and
    // the list does not redraw (as NetState's rows).
    readonly property string rowsJson: JSON.stringify(BtModel.rows(BtModel.snapshot(Bluetooth.devices ? Bluetooth.devices.values : []), root.discovering))
    readonly property var rows: JSON.parse(root.rowsJson)
    readonly property int connectedCount: root.rows.filter(r => r.connected).length

    // The one action running: its address and kind, "" when idle.
    property string actionAddress: ""
    property string actionKind: ""
    readonly property bool busy: root.actionAddress !== ""
    // address -> the action that last failed on it, until the next try.
    property var failures: ({})
    property bool powerBusy: false

    function act(row) {
        root.run(BtModel.actionFor(row), row.address);
    }

    function forget(row) {
        if (BtModel.canForget(row))
            root.run("forget", row.address);
    }

    function run(kind, address) {
        if (root.busy || address === "")
            return;
        var f = Object.assign({}, root.failures);
        delete f[address];
        root.failures = f;
        root.actionAddress = address;
        root.actionKind = kind;
        root.device.command = ["sarisarinama-bluetooth-device", kind, address];
        root.device.running = true;
    }

    // Asks for a direction, not a toggle: the switch moves only once BlueZ
    // catches up, so a second click in between would undo the first.
    function setPower(on) {
        if (!root.available || root.powerBusy)
            return;
        root.powerBusy = true;
        root.power.command = ["sarisarinama-bluetooth-power", on ? "on" : "off"];
        root.power.running = true;
    }

    function togglePower() {
        root.setPower(!root.on);
    }

    // Starts the scan over.
    function rescan() {
        if (root.discovering)
            root.adapter.discovering = false;
    }

    property Process device: Process {
        onExited: (code, status) => {
            if (code !== 0) {
                var f = Object.assign({}, root.failures);
                f[root.actionAddress] = root.actionKind;
                root.failures = f;
            }
            root.actionAddress = "";
            root.actionKind = "";
        }
    }

    property Process power: Process {
        onExited: root.powerBusy = false
    }

    // Whether this panel started the scan running and so owes its stop.
    property bool owesStop: false

    // BlueZ's scan can end on its own, and Quickshell forwards a write only
    // when it differs from the last one, so the scan is asked for again
    // until it runs, every second while the panel is open.
    property Timer scanStart: Timer {
        interval: 1000
        repeat: true
        triggeredOnStart: true
        running: root.active && root.on && !root.adapter.discovering
        onTriggered: {
            root.owesStop = true;
            root.adapter.discovering = true;
        }
    }

    // The way down, the same way: asked again until BlueZ confirms it, and
    // only for a scan this panel started.
    property Timer scanStop: Timer {
        interval: 1000
        repeat: true
        triggeredOnStart: true
        running: !root.active && root.owesStop && root.available && root.adapter.discovering
        onTriggered: root.adapter.discovering = false
    }

    property Connections settle: Connections {
        target: root.adapter
        function onDiscoveringChanged() {
            if (!root.adapter.discovering && !root.active)
                root.owesStop = false;
        }
    }
}
