// quickshell/compositor/Hypr.qml
// The Hyprland backend, reached only through Compositor.qml. Named Hypr and
// not Hyprland because a local file loses to a type of the same name from an
// imported module, and Quickshell.Hyprland exports `Hyprland`.
import Quickshell.Hyprland
import QtQuick

QtObject {
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
}
