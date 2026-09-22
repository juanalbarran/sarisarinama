// quickshell/shell.qml
import QtQuick
import Quickshell
import Quickshell.Io
import "bar"
import "menu"

ShellRoot {
    id: shell

    Bar {}

    // Fixed component table. No manifests, no discovery: adding a
    // component means adding one line here.
    property var components: ({
            "menu": menuLoader
        })

    Loader {
        id: menuLoader
        active: false
        sourceComponent: Menu {}
    }

    function summon(id, payloadJson) {
        var loader = components[id];
        if (!loader)
            return "unknown";
        loader.active = true;
        loader.item.open(payloadJson || "{}");
        return "ok";
    }

    function hide(id) {
        var loader = components[id];
        if (loader && loader.item)
            loader.item.close();
    }

    function isOpen(id) {
        var loader = components[id];
        return !!(loader && loader.item && loader.item.opened);
    }

    IpcHandler {
        target: "shell"

        function summon(id: string, payload: string): string {
            return shell.summon(id, payload);
        }

        function hide(id: string): void {
            shell.hide(id);
        }

        function toggle(id: string, payload: string): string {
            if (shell.isOpen(id)) {
                shell.hide(id);
                return "ok";
            }
            return shell.summon(id, payload);
        }
    }
}
