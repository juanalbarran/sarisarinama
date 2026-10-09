// quickshell/shell.qml
import QtQuick
import Quickshell
import Quickshell.Io
import "theme"
import "bar"
import "menu"
import "panes/network"

ShellRoot {
    id: shell

    Bar {
        onNetworkClicked: shell.toggle("network", "{}")
    }
    ThemeIpc {}

    // Fixed component table. No manifests, no discovery: adding a
    // component means adding one line here.
    property var components: ({
            "menu": menuLoader,
            "network": networkLoader
        })

    Loader {
        id: menuLoader
        active: false
        sourceComponent: Menu {}
    }

    Loader {
        id: networkLoader
        active: false
        sourceComponent: NetworkPanel {}
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

    function toggle(id, payloadJson) {
        if (isOpen(id)) {
            hide(id);
            return "ok";
        }
        return summon(id, payloadJson);
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
            return shell.toggle(id, payload);
        }
    }
}
