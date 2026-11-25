// quickshell/compositor/OutputMemory.qml
// The displays as the monitor panel last left them, on or off and their
// scale, kept in $XDG_STATE_HOME/sarisarinama/outputs.json so a Hyprland
// reload, which resets every display to its defaults, does not undo them.
// Compositor.qml records each change here and asks for a plan to put them
// back. Only with an external display connected: without one the laptop
// panel is all there is, so it is left as the compositor has it.
import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    // {name: {active, scale}}; a display the panel never changed is absent.
    property var saved: ({})
    // True once the file has been read, or found missing.
    property bool ready: false

    function remember(name, change) {
        var next = Object.assign({}, root.saved);
        next[name] = Object.assign({}, next[name] || {}, change);
        root.saved = next;
        root.file.setText(JSON.stringify(next) + "\n");
    }

    // The same test as monmodel.js and sarisarinama-lid.
    function isInternal(name) {
        return /^(eDP|LVDS|DSI)-/.test(name);
    }

    // The changes that put `outputs` back as saved, as
    // [{kind: "on" | "scale" | "off", name, scale}]: displays on first, then
    // scales, then off, so one is always on. Empty without an external
    // display, or when the saved state would leave none on.
    function plan(outputs) {
        if (!outputs.some(o => !root.isInternal(o.name)))
            return [];
        var want = o => {
            var s = root.saved[o.name];
            return s && s.active !== undefined ? s.active : o.active;
        };
        if (!outputs.some(want))
            return [];
        var steps = [];
        outputs.forEach(o => {
            if (want(o) && !o.active)
                steps.push({ kind: "on", name: o.name });
        });
        // A display just turned on comes up at the compositor's own scale,
        // so its saved one is set whatever it reads now.
        outputs.forEach(o => {
            var s = root.saved[o.name];
            if (want(o) && s && s.scale !== undefined && (!o.active || Math.abs(s.scale - o.scale) > 0.001))
                steps.push({ kind: "scale", name: o.name, scale: s.scale });
        });
        outputs.forEach(o => {
            if (!want(o) && o.active)
                steps.push({ kind: "off", name: o.name });
        });
        return steps;
    }

    property FileView file: FileView {
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/sarisarinama/outputs.json"
        printErrors: false
        onLoaded: {
            try {
                var parsed = JSON.parse(text());
                root.saved = parsed && typeof parsed === "object" ? parsed : {};
            } catch (e) {
                root.saved = {};
            }
            root.ready = true;
        }
        onLoadFailed: root.ready = true
    }
}
