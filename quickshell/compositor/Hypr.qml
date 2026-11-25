// quickshell/compositor/Hypr.qml
// The Hyprland backend, reached only through Compositor.qml. Named Hypr and
// not Hyprland because a local file loses to a type of the same name from an
// imported module, and Quickshell.Hyprland exports `Hyprland`.
//
// Outputs are read from `hyprctl monitors all -j`, which also lists the
// disabled ones, and changed with `hyprctl keyword monitor`. Untested:
// Hyprland is not ported yet, and a Hyprland on the Lua config rejects
// `hyprctl keyword`.
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    function workspace(n) {
        return Hyprland.workspaces.values.find(w => w.id === n) ?? null;
    }

    function activate(n) {
        var ws = workspace(n);
        if (ws)
            ws.activate();
        else
            Hyprland.dispatch("workspace " + n);
    }

    // [{name, description, active, focused, scale, width, height}], the
    // same shape as Sway.qml's.
    property var outputs: []

    function refreshOutputs() {
        if (!root.reader.running)
            root.reader.running = true;
    }

    function setOutputEnabled(name, enabled) {
        root.run(["hyprctl", "keyword", "monitor", name + (enabled ? ",preferred,auto,auto" : ",disable")]);
    }

    function setOutputScale(name, scale) {
        root.run(["hyprctl", "keyword", "monitor", name + ",preferred,auto," + scale]);
    }

    // How the windows look, asked of Hyprland so the bar follows its config:
    // gaps_out in CSS order (top right bottom left) and the corner radius.
    property var gaps: ({ top: 0, right: 0, bottom: 0, left: 0 })
    property int rounding: 0

    // The config was reloaded, which resets every display to its rules.
    signal reloaded

    // One batched call; the answers come back as JSON objects separated by
    // blank lines, in the order they were asked.
    property Process looksReader: Process {
        running: true
        command: ["hyprctl", "-j", "--batch", "getoption general:gaps_out; getoption decoration:rounding"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var o = text.split(/\n\s*\n/).filter(s => s.trim()).map(s => JSON.parse(s));
                    var g = o[0].custom.split(" ").map(Number);
                    root.gaps = { top: g[0], right: g[1], bottom: g[2], left: g[3] };
                    root.rounding = o[1].int;
                } catch (e) {
                    console.warn("hyprland: cannot read gaps or rounding", e);
                }
            }
        }
    }

    // A `hyprctl reload` can change both, so read them again.
    property Connections reload: Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded") {
                root.looksReader.running = true;
                root.reloaded();
            }
        }
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
        command: ["hyprctl", "monitors", "all", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.outputs = JSON.parse(text).map(m => ({
                                name: m.name,
                                description: [m.make, m.model].filter(s => s).join(" "),
                                active: m.disabled !== true,
                                focused: m.focused === true,
                                scale: m.disabled ? 1 : m.scale,
                                width: m.disabled ? 0 : m.width,
                                height: m.disabled ? 0 : m.height
                            }));
                } catch (e) {
                    console.warn("hyprland: cannot read outputs", e);
                }
            }
        }
    }

    property Process writer: Process {
        onExited: root.next()
    }
}
