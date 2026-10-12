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

    // Every output, the disabled ones too:
    // [{name, description, active, focused, scale, width, height}].
    // Not live: it changes when refreshOutputs() has read them again, which
    // every change below does by itself.
    readonly property var outputs: root.backend.item ? root.backend.item.outputs : []

    function refreshOutputs() {
        if (root.backend.item)
            root.backend.item.refreshOutputs();
    }

    function setOutputEnabled(name, enabled) {
        if (root.backend.item)
            root.backend.item.setOutputEnabled(name, enabled);
    }

    function setOutputScale(name, scale) {
        if (root.backend.item)
            root.backend.item.setOutputScale(name, scale);
    }
}
