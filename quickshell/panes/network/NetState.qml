// quickshell/panes/network/NetState.qml
// What NetworkManager says, read live through Quickshell.Networking. Every
// property is a binding over NetworkManager's own objects, so the panel
// follows a change the moment it happens, with no polling. The panel's
// sections read from here and call its functions; none of them talks to
// NetworkManager directly.
import QtQuick
import Quickshell.Networking
import "netmodel.js" as NetModel

QtObject {
    id: root

    // True while the panel is open. Only then is the radio asked to scan:
    // scanning costs power, and nothing shows the list while closed.
    property bool active: false

    readonly property bool available: Networking.backend === NetworkBackendType.NetworkManager
    readonly property var devices: Networking.devices ? Networking.devices.values : []
    readonly property var wifiDevice: NetModel.findDevice(devices, DeviceType.Wifi)
    readonly property var wiredDevice: NetModel.findDevice(devices, DeviceType.Wired)
    readonly property var wifiNetworks: wifiDevice ? wifiDevice.networks.values : []
    readonly property var connectedWifi: wifiNetworks.find(n => n && n.connected) ?? null

    // The device is trusted over the network: right after start-up a
    // connected device can list its network as not connected for a moment.
    readonly property string kind: {
        if (wiredDevice && wiredDevice.connected)
            return "ethernet";
        if (wifiDevice && wifiDevice.connected)
            return "wifi";
        return "disconnected";
    }

    readonly property int signal: connectedWifi ? Math.round(connectedWifi.signalStrength * 100) : -1
    readonly property bool portal: kind !== "disconnected" && Networking.connectivity === NetworkConnectivity.Portal
    readonly property bool restricted: portal || (kind !== "disconnected" && Networking.connectivity === NetworkConnectivity.Limited)
    readonly property string icon: NetModel.icon(kind, signal, restricted)

    readonly property string title: {
        if (kind === "wifi")
            return connectedWifi ? connectedWifi.name : "Wi-Fi";
        if (kind === "ethernet") {
            var speed = NetModel.formatSpeed(wiredDevice.linkSpeed);
            return speed ? "Ethernet (" + speed + ")" : "Ethernet";
        }
        return "Disconnected";
    }

    readonly property string status: {
        if (!available)
            return "NETWORKMANAGER IS NOT RUNNING";
        if (portal)
            return "SIGN-IN REQUIRED";
        if (restricted)
            return "LIMITED INTERNET ACCESS";
        if (kind !== "disconnected")
            return "CONNECTED";
        return wifiEnabled ? "NOT CONNECTED" : "WI-FI IS OFF";
    }

    // The switch is the Wi-Fi radio, so it exists only when there is one.
    readonly property bool canToggleWifi: available && wifiDevice !== null
    readonly property bool wifiEnabled: Networking.wifiEnabled

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    // The device this object turned the scanner on for, so it can be turned
    // off again even if NetworkManager replaces the device meanwhile.
    property var scanning: null

    function syncScanner() {
        var next = root.active ? root.wifiDevice : null;
        if (root.scanning && root.scanning !== next)
            root.scanning.scannerEnabled = false;
        root.scanning = next;
        if (next)
            next.scannerEnabled = true;
    }

    // Turns the scanner off and on again, which starts a fresh scan. The
    // pause lets NetworkManager see the off before the on.
    function rescan() {
        if (!root.scanning)
            return;
        root.scanning.scannerEnabled = false;
        rescanTimer.restart();
    }

    property Timer rescanTimer: Timer {
        interval: 100
        onTriggered: root.syncScanner()
    }

    onActiveChanged: {
        syncScanner();
        // A prompt or an error belongs to this opening of the panel.
        if (!active) {
            cancelPassword();
            failedSsid = "";
            failure = "";
        }
    }
    onWifiDeviceChanged: syncScanner()
    Component.onDestruction: {
        if (root.scanning)
            root.scanning.scannerEnabled = false;
    }

    // ---- The Wi-Fi list ----

    // The enum values netmodel.js needs, since a .js file sees no QML types.
    readonly property var security: ({
            open: WifiSecurityType.Open,
            owe: WifiSecurityType.Owe,
            enterprise: [WifiSecurityType.Wpa2Eap, WifiSecurityType.WpaEap, WifiSecurityType.Wpa3SuiteB192]
        })
    readonly property var reasons: ({
            noSecrets: ConnectionFailReason.NoSecrets,
            authTimeout: ConnectionFailReason.WifiAuthTimeout,
            networkLost: ConnectionFailReason.WifiNetworkLost,
            clientDisconnected: ConnectionFailReason.WifiClientDisconnected
        })

    // The list, written out as text first. A string property announces a
    // change only when its value really differs, so `rows` is rebuilt when
    // something the list shows has changed, not every time NetworkManager
    // touches a network. A network with no name (a hidden one) cannot be
    // picked by name, so it is left out.
    readonly property string rowsJson: JSON.stringify(NetModel.withHeadings(NetModel.sortRows(wifiNetworks.filter(n => n && n.name).map(n => NetModel.wifiRow(n, security)))))
    readonly property var rows: JSON.parse(rowsJson)

    // One action at a time, named by the network it acts on.
    property string actionSsid: ""
    property string actionKind: ""   // "connect" | "disconnect" | "forget"
    readonly property bool busy: actionKind !== ""

    // The last action that failed, shown on its row until the next one.
    property string failedSsid: ""
    property string failure: ""

    // The row whose password prompt is open, and what has been typed in it.
    // The text lives here so a list refresh that rebuilds the row keeps it.
    property string passwordSsid: ""
    property string passwordText: ""

    function networkFor(ssid) {
        return wifiNetworks.find(n => n && n.name === ssid) ?? null;
    }

    // What a click on a row does.
    function activate(row) {
        if (busy)
            return;
        if (row.connected)
            run("disconnect", row.ssid, n => n.disconnect());
        else if (row.enterprise && !row.known)
            fail(row.ssid, "Enterprise networks are not supported yet");
        else if (row.secured && !row.known)
            askPassword(row.ssid);
        else
            run("connect", row.ssid, n => n.connect());
    }

    function connectWithPassword(ssid) {
        var password = root.passwordText;
        if (password.length > 0)
            run("connect", ssid, n => n.connectWithPsk(password));
    }

    function forget(row) {
        if (NetModel.canForget(row))
            run("forget", row.ssid, n => n.forget());
    }

    function askPassword(ssid) {
        failedSsid = "";
        failure = "";
        passwordText = "";
        passwordSsid = ssid;
    }

    function cancelPassword() {
        passwordSsid = "";
        passwordText = "";
    }

    function run(kind, ssid, action) {
        var network = networkFor(ssid);
        if (busy || !network)
            return;
        failedSsid = "";
        failure = "";
        actionSsid = ssid;
        actionKind = kind;
        actionTimeout.restart();
        action(network);
    }

    function finish() {
        actionTimeout.stop();
        if (actionKind === "connect")
            cancelPassword();
        actionSsid = "";
        actionKind = "";
    }

    // Leaves the prompt open: after a wrong password it is where the fix goes.
    function fail(ssid, text) {
        actionTimeout.stop();
        failedSsid = ssid;
        failure = text;
        actionSsid = "";
        actionKind = "";
    }

    // Done when NetworkManager reports the state the action asked for.
    function checkAction() {
        if (!busy)
            return;
        var n = networkFor(actionSsid);
        if (!n) {
            // A forgotten network that is out of range leaves the list.
            if (actionKind === "forget")
                finish();
            return;
        }
        if (actionKind === "connect" && n.connected)
            finish();
        else if (actionKind === "disconnect" && !n.connected && !n.stateChanging)
            finish();
        else if (actionKind === "forget" && !n.known && !n.stateChanging)
            finish();
    }

    function connectFailed(reason) {
        // NetworkManager's own retries fail too; only ours are reported.
        if (actionKind !== "connect")
            return;
        var ssid = actionSsid;
        var row = rows.find(r => r.ssid === ssid);
        var secured = row ? row.secured : true;
        fail(ssid, NetModel.failureText(reason, secured, reasons));
        if (NetModel.shouldAskPassword(reason, secured, reasons)) {
            passwordText = "";
            passwordSsid = ssid;
        }
    }

    // A network that leaves the list sends no signal of its own, but the
    // list changes; that is when a forgotten, out-of-range one is done.
    onRowsJsonChanged: checkAction()

    readonly property var actionNetwork: actionSsid !== "" ? networkFor(actionSsid) : null

    property Connections watch: Connections {
        target: root.actionNetwork
        function onConnectedChanged() {
            root.checkAction();
        }
        function onKnownChanged() {
            root.checkAction();
        }
        function onStateChangingChanged() {
            root.checkAction();
        }
        function onConnectionFailed(reason) {
            root.connectFailed(reason);
        }
    }

    // A last resort if NetworkManager never answers. Longer than its own
    // 25 s limit, so a wrong saved password still arrives as "Wrong password".
    property Timer actionTimeout: Timer {
        interval: 30000
        onTriggered: root.fail(root.actionSsid, "Timed out")
    }
}
