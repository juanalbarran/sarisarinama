// quickshell/panes/network/NetStats.qml
// The numbers NetworkManager does not give: rates, totals and ping. While
// the panel is open, sarisarinama-network-status is run every 1.5 s and
// each sample is compared with the one before it. Closed, nothing runs and
// the history is dropped, so the next opening does not compare against a
// sample from minutes ago.
import QtQuick
import Quickshell.Io
import "statsmodel.js" as StatsModel

QtObject {
    id: root

    property bool active: false

    // The last sample: {iface, ip, prefix, gateway, rx_bytes, tx_bytes,
    // ping_ms}, or {} before the first one or without a connection.
    property var sample: ({})
    property var counters: null
    property var pings: []

    // How many pings the loss figure covers (~36 s), and the average (~7 s).
    readonly property int lossWindow: 24
    readonly property int averageWindow: 5

    readonly property bool connected: sample.iface !== undefined
    readonly property bool hasPings: pings.length > 0
    readonly property real download: counters ? counters.download : 0
    readonly property real upload: counters ? counters.upload : 0
    readonly property real ping: StatsModel.averagePing(pings, averageWindow)
    readonly property int loss: StatsModel.packetLoss(pings)

    function update(text) {
        var next = StatsModel.parseSample(text);
        if (next.iface === undefined) {
            reset();
            return;
        }
        // A new interface starts a new history.
        if (sample.iface !== next.iface)
            pings = [];
        counters = StatsModel.rates(counters, next, Date.now() / 1000);
        pings = StatsModel.addPing(pings, next.ping_ms, lossWindow);
        sample = next;
    }

    function reset() {
        sample = {};
        counters = null;
        pings = [];
    }

    onActiveChanged: if (!active)
        reset()

    property Process probe: Process {
        command: ["sarisarinama-network-status"]
        stdout: StdioCollector {
            onStreamFinished: root.update(text)
        }
    }

    // A sample whose ping times out takes about a second; one still running
    // when the next is due is left to finish rather than started twice.
    property Timer poll: Timer {
        interval: 1500
        repeat: true
        triggeredOnStart: true
        running: root.active
        onTriggered: {
            if (!root.probe.running)
                root.probe.running = true;
        }
    }
}
