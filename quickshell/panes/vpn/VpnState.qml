// quickshell/panes/vpn/VpnState.qml
// The VPN profiles NetworkManager knows, and the one change the panel can
// make: a profile up or down. Quickshell.Networking has no VPN type, so
// this asks nmcli: when the panel opens, after every change, and every
// few seconds while it is open, which is how a tunnel that drops shows up.
import QtQuick
import Quickshell.Io
import "vpnmodel.js" as VpnModel

QtObject {
    id: root

    // True while the panel is open; only then is nmcli polled.
    property bool active: false

    property var profiles: []
    readonly property var connected: profiles.find(p => p.state === "activated") ?? null

    // One change at a time, named by the profile it acts on, and whether
    // it brings the profile up or down.
    property string busyUuid: ""
    property bool busyUp: false
    readonly property bool busy: busyUuid !== ""

    // The last change that failed, shown on its row until the next one.
    property string error: ""
    property string errorUuid: ""

    function refresh() {
        if (!probe.running)
            probe.running = true;
    }

    function toggle(uuid) {
        var profile = profiles.find(p => p.uuid === uuid);
        if (busy || !profile)
            return;
        busyUuid = uuid;
        busyUp = !VpnModel.isUp(profile);
        error = "";
        errorUuid = "";
        // Arguments, never a shell line: a profile name is never run.
        change.command = ["nmcli", "--wait", "30", "connection", busyUp ? "up" : "down", "uuid", uuid];
        change.running = true;
    }

    onActiveChanged: {
        if (active) {
            refresh();
        } else {
            error = "";
            errorUuid = "";
        }
    }

    property Process probe: Process {
        command: ["nmcli", "-t", "-f", "NAME,UUID,TYPE,STATE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                var next = VpnModel.parse(text);
                // The same list assigned again would rebuild every row; only
                // a real change is passed on.
                if (JSON.stringify(next) !== JSON.stringify(root.profiles))
                    root.profiles = next;
            }
        }
    }

    property Process change: Process {
        stderr: StdioCollector {
            id: changeErrors
            waitForEnd: true
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.errorUuid = root.busyUuid;
                root.error = VpnModel.errorText(changeErrors.text);
            }
            root.busyUuid = "";
            root.refresh();
        }
    }

    // Faster than NetSettings: a tunnel can drop at any moment, and the
    // panel should not show it up for long after it has gone.
    property Timer poll: Timer {
        interval: 3000
        repeat: true
        running: root.active
        onTriggered: root.refresh()
    }
}
