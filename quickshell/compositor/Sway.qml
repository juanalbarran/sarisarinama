// quickshell/compositor/Sway.qml
// The Sway/i3 backend, reached only through Compositor.qml. I3Workspace
// numbers itself `num`. A workspace that does not exist yet has no object
// to activate, so it is summoned by command instead.
//
// Outputs are read from `swaymsg -t get_outputs`, which also lists the
// disabled ones, and changed with `swaymsg output`. swaymsg comes from
// PATH: only the running Sway's own copy is sure to speak its protocol.
import Quickshell.I3
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    function workspace(n) {
        return I3.workspaces.values.find(w => w.num === n) ?? null;
    }

    function activate(n) {
        var ws = workspace(n);
        if (ws)
            ws.activate();
        else
            I3.dispatch("workspace number " + n);
    }

    // [{name, description, active, focused, scale, width, height}]; width
    // and height are 0 for a disabled output.
    property var outputs: []

    function refreshOutputs() {
        if (!root.reader.running)
            root.reader.running = true;
    }

    function setOutputEnabled(name, enabled) {
        root.run(["swaymsg", "output", name, enabled ? "enable" : "disable"]);
    }

    function setOutputScale(name, scale) {
        root.run(["swaymsg", "output", name, "scale", String(scale)]);
    }

    // Changes run one at a time, in the order they were asked for; a change
    // asked for while another runs waits its turn instead of being lost.
    // The outputs are read again once the last one is done.
    property var queue: []

    function run(command) {
        root.queue = root.queue.concat([command]);
        if (!root.writer.running)
            root.next();
    }

    function next() {
        if (root.queue.length === 0) {
            root.refreshOutputs();
            return;
        }
        root.writer.command = root.queue[0];
        root.queue = root.queue.slice(1);
        root.writer.running = true;
    }

    property Process reader: Process {
        command: ["swaymsg", "-t", "get_outputs", "-r"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.outputs = JSON.parse(text).map(o => ({
                                name: o.name,
                                description: [o.make, o.model].filter(s => s && s !== "Unknown").join(" "),
                                active: o.active === true,
                                focused: o.focused === true,
                                scale: o.active ? o.scale : 1,
                                width: o.current_mode ? o.current_mode.width : 0,
                                height: o.current_mode ? o.current_mode.height : 0
                            }));
                } catch (e) {
                    console.warn("sway: cannot read outputs", e);
                }
            }
        }
    }

    property Process writer: Process {
        onExited: root.next()
    }
}
