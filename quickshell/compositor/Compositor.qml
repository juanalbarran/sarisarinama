// quickshell/compositor/Compositor.qml
// The compositor, whichever one is running. Sway and Hyprland disagree on
// how a workspace is numbered and how you switch to one; everything else
// the bar reads — focused, urgent — is spelled the same on both, so it is
// passed through live rather than copied. Outputs are the exception: each
// backend reads them with its own command and hands back the same shape.
// See docs/bar.md.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    // Hyprland exports this into every client it launches; Sway does not.
    readonly property string name: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ? "hyprland" : "sway"

    // Loaded by URL, never as a type: the losing backend's file is never
    // compiled, so its import never reaches for a socket that is not there.
    readonly property Loader backend: Loader {
        source: root.name === "hyprland" ? "Hypr.qml" : "Sway.qml"
        // The outputs are read once at start, so the saved ones can be put
        // back without the panel ever opening.
        onLoaded: root.refreshOutputs()
    }

    // The live workspace object, or null. Callers read .focused and .urgent
    // off it themselves — reading them here would freeze them.
    function workspace(n) {
        return root.backend.item ? root.backend.item.workspace(n) : null;
    }

    function activate(n) {
        if (root.backend.item)
            root.backend.item.activate(n);
    }

    // How the windows look: their distance from the screen edges and their
    // corner radius. Both zero on Sway, which draws neither.
    readonly property var gaps: root.backend.item ? root.backend.item.gaps : ({ top: 0, right: 0, bottom: 0, left: 0 })
    readonly property int rounding: root.backend.item ? root.backend.item.rounding : 0

    // The display with the focus, by name, live.
    readonly property string focusedOutput: root.backend.item ? root.backend.item.focusedOutput : ""

    // Every output, the disabled ones too:
    // [{name, description, active, focused, scale, width, height}].
    // Not live: it changes when refreshOutputs() has read them again, which
    // every change below does by itself.
    readonly property var outputs: root.backend.item ? root.backend.item.outputs : []

    function refreshOutputs() {
        if (root.backend.item)
            root.backend.item.refreshOutputs();
    }

    // Both remember the change, so a reload or a restart puts it back.
    function setOutputEnabled(name, enabled) {
        root.memory.remember(name, { active: enabled });
        if (root.backend.item)
            root.backend.item.setOutputEnabled(name, enabled);
    }

    function setOutputScale(name, scale) {
        root.memory.remember(name, { scale: Number(scale) });
        if (root.backend.item)
            root.backend.item.setOutputScale(name, scale);
    }

    // The displays as the panel last left them, put back once both the file
    // and the outputs are read: at start, and after a compositor reload.
    readonly property OutputMemory memory: OutputMemory {
        onReadyChanged: root.restore()
    }
    property bool restorePending: true

    onOutputsChanged: root.restore()

    function restore() {
        if (!root.restorePending || !root.memory.ready || root.outputs.length === 0 || !root.backend.item)
            return;
        root.restorePending = false;
        // Straight to the backend: these are not new choices to remember.
        root.memory.plan(root.outputs).forEach(step => {
            if (step.kind === "scale")
                root.backend.item.setOutputScale(step.name, step.scale);
            else
                root.backend.item.setOutputEnabled(step.name, step.kind === "on");
        });
    }

    readonly property Connections reloads: Connections {
        target: root.backend.item
        ignoreUnknownSignals: true
        function onReloaded() {
            root.restorePending = true;
            root.refreshOutputs();
        }
    }
}
