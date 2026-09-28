// quickshell/compositor/Sway.qml
// The Sway/i3 backend, reached only through Compositor.qml. I3Workspace
// numbers itself `num`. A workspace that does not exist yet has no object
// to activate, so it is summoned by command instead.
import Quickshell.I3
import QtQuick

QtObject {
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
}
