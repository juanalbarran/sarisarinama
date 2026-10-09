// quickshell/panes/network/NetSettings.qml
// The two settings the panel can change on the connected network: its
// Wi-Fi band and its DNS. Their state comes from sarisarinama-network-band
// and sarisarinama-network-dns, read when the panel opens and every few
// seconds while it is open. A change runs the same script with the choice,
// one change at a time, and reads the state again when it is done.
import QtQuick
import Quickshell.Io
import "../../theme/"
import "statsmodel.js" as StatsModel
import "settingsmodel.js" as SettingsModel

QtObject {
    id: root

    property bool active: false

    // The DNS providers, from ~/.config/sarisarinama/network.json, after
    // DHCP: the network's own servers, always offered first.
    readonly property ConfigFile config: ConfigFile {
        name: "network"
    }
    readonly property var providers: [
        {
            name: "DHCP",
            servers: []
        }
    ].concat(config.value("dnsProviders", []))

    property var band: ({})
    property var dns: ({})

    // The row a change is running on ("band" or "dns"), and what was asked:
    // the row shows the choice at once rather than after the reconnect.
    property string changing: ""
    property string pending: ""

    // The last change that failed, and its row.
    property string error: ""
    property string errorRow: ""

    readonly property var bandOptions: SettingsModel.bandOptions(band)
    readonly property string bandSelected: changing === "band" ? pending : (band.selected || "")
    readonly property bool bandShown: SettingsModel.bandWorthShowing(band)

    readonly property string dnsSelected: changing === "dns" ? pending : SettingsModel.providerFor(dns, providers)
    readonly property bool dnsShown: dns.profile !== undefined

    function refresh() {
        if (!bandProbe.running)
            bandProbe.running = true;
        if (!dnsProbe.running)
            dnsProbe.running = true;
    }

    function setBand(choice) {
        if (changing === "" && bandOptions.indexOf(choice) >= 0 && choice !== band.selected)
            run("band", choice, ["sarisarinama-network-band", choice]);
    }

    function setDns(name) {
        var provider = providers.find(p => p.name === name);
        if (changing !== "" || !provider || name === dnsSelected)
            return;
        if (name === "DHCP")
            run("dns", name, ["sarisarinama-network-dns", "dhcp"]);
        else
            run("dns", name, ["sarisarinama-network-dns", "set"].concat(provider.servers));
    }

    // The servers go to the script as separate arguments, never through a
    // shell, so nothing in them is ever run as a command.
    function run(row, choice, command) {
        changing = row;
        pending = choice;
        error = "";
        errorRow = "";
        change.command = command;
        change.running = true;
    }

    onActiveChanged: {
        if (active) {
            refresh();
        } else {
            error = "";
            errorRow = "";
        }
    }

    property Process bandProbe: Process {
        command: ["sarisarinama-network-band"]
        stdout: StdioCollector {
            onStreamFinished: {
                var next = SettingsModel.bandStatus(StatsModel.parseSample(text));
                // Mid-reconnect there is no band to report; keep the last one
                // so the row does not vanish under a change it is making.
                if (next.selected === undefined && root.changing === "band")
                    return;
                root.band = next;
            }
        }
    }

    property Process dnsProbe: Process {
        command: ["sarisarinama-network-dns"]
        stdout: StdioCollector {
            onStreamFinished: {
                var next = SettingsModel.dnsStatus(StatsModel.parseSample(text));
                if (next.profile === undefined && root.changing === "dns")
                    return;
                root.dns = next;
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
                root.errorRow = root.changing;
                root.error = changeErrors.text.trim() || "Could not change it";
            }
            root.changing = "";
            root.pending = "";
            root.refresh();
        }
    }

    // Slow on purpose: band availability only moves when a scan turns up a
    // new access point, and DNS only when something changes it.
    property Timer poll: Timer {
        interval: 4000
        repeat: true
        running: root.active
        onTriggered: root.refresh()
    }
}
