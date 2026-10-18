// quickshell/panes/audio/AudioState.qml
// The outputs, inputs and apps PipeWire knows, and the changes the panel
// can make: a volume, a mute, the default device. Nothing is polled:
// Quickshell follows PipeWire. The lists handed to the panel are
// snapshots of ids and names (see audiomodel.js), taken while it is open.
import QtQuick
import Quickshell.Services.Pipewire
import "audiomodel.js" as AudioModel

QtObject {
    id: root

    // True while the panel is open; only then are nodes bound and listed.
    property bool active: false

    readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property var outputs: AudioModel.pick(nodes, AudioModel.isOutput)
    readonly property var inputs: AudioModel.pick(nodes, AudioModel.isInput)
    readonly property var apps: AudioModel.pick(nodes, AudioModel.isApp)

    property var outputRows: []
    property var inputRows: []
    property var appRows: []

    // The node a row was taken from, or null once PipeWire has removed it.
    function nodeFor(row) {
        if (!row)
            return null;
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i];
            if (n && n.id === row.id && String(n.name || "") === row.name)
                return n;
        }
        return null;
    }

    function nodeById(id) {
        var all = outputRows.concat(inputRows, appRows);
        return nodeFor(all.find(r => r.id === id));
    }

    function setVolume(node, v) {
        if (node && node.audio)
            node.audio.volume = Math.max(0, Math.min(1, v));
    }

    function nudge(node, delta) {
        if (node && node.audio)
            setVolume(node, node.audio.volume + delta);
    }

    function toggleMute(node) {
        if (node && node.audio)
            node.audio.muted = !node.audio.muted;
    }

    // WirePlumber keeps the choice, so it survives a restart.
    function setDefault(node) {
        if (!node)
            return;
        if (node.isSink)
            Pipewire.preferredDefaultAudioSink = node;
        else
            Pipewire.preferredDefaultAudioSource = node;
    }

    // Only a real change is passed on, so rows are not rebuilt for nothing.
    function refresh() {
        var next = AudioModel.rows(outputs);
        if (!AudioModel.sameRows(next, outputRows))
            outputRows = next;
        next = AudioModel.rows(inputs);
        if (!AudioModel.sameRows(next, inputRows))
            inputRows = next;
        next = AudioModel.rows(apps);
        if (!AudioModel.sameRows(next, appRows))
            appRows = next;
    }

    function schedule() {
        if (active)
            settle.restart();
    }

    onOutputsChanged: schedule()
    onInputsChanged: schedule()
    onAppsChanged: schedule()

    onActiveChanged: {
        if (active) {
            refresh();
        } else {
            settle.stop();
            outputRows = [];
            inputRows = [];
            appRows = [];
        }
    }

    // A node appearing or going away arrives as a burst of changes; the
    // snapshot is taken once they settle, never mid-removal.
    property Timer settle: Timer {
        interval: 50
        onTriggered: root.refresh()
    }

    // A node's volume, mute and properties are only live while it is bound.
    property PwObjectTracker tracker: PwObjectTracker {
        objects: root.active ? [root.sink, root.source].concat(root.outputs, root.inputs, root.apps).filter(n => n) : []
    }
}
