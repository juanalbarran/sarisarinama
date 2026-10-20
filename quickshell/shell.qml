// quickshell/shell.qml
import QtQuick
import Quickshell
import Quickshell.Io
import "theme"
import "bar"
import "menu"
import "panes/network"
import "panes/monitor"
import "panes/vpn"
import "panes/battery"
import "panes/audio"
import "panes/keybinds"
import "lock"
import "wallpaper"

ShellRoot {
    id: shell

    Bar {
        onNetworkClicked: shell.toggle("network", "{}")
        onBatteryClicked: shell.toggle("battery", "{}")
        onAudioClicked: shell.toggle("audio", "{}")
        onVpnClicked: shell.toggle("vpn", "{}")
    }
    ThemeIpc {}
    LockScreen {}
    Wallpaper {}

    // Fixed component table. No manifests, no discovery: adding a
    // component means adding one line here.
    property var components: ({
            "menu": menuLoader,
            "network": networkLoader,
            "monitor": monitorLoader,
            "vpn": vpnLoader,
            "battery": batteryLoader,
            "audio": audioLoader,
            "keybinds": keybindsLoader
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

    Loader {
        id: monitorLoader
        active: false
        sourceComponent: MonitorPanel {}
    }

    Loader {
        id: vpnLoader
        active: false
        sourceComponent: VpnPanel {}
    }

    Loader {
        id: batteryLoader
        active: false
        sourceComponent: BatteryPanel {}
    }

    Loader {
        id: audioLoader
        active: false
        sourceComponent: AudioPanel {}
    }

    Loader {
        id: keybindsLoader
        active: false
        sourceComponent: KeybindsPanel {}
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
