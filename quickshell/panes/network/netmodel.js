// quickshell/panes/network/netmodel.js
// Plain functions for the network panel: they take values and return
// values, and know nothing about QML. Ported from omarchy's Model.js.

// The first device of a type, preferring a connected one: a laptop can
// have an idle onboard port next to the adapter actually in use.
function findDevice(devices, type) {
    var fallback = null;
    for (var i = 0; i < devices.length; i++) {
        var d = devices[i];
        if (!d || d.type !== type)
            continue;
        if (d.connected)
            return d;
        if (!fallback)
            fallback = d;
    }
    return fallback;
}

// Five bars, one per 20% of signal. -1 means "not known yet": full bars,
// since the device already says it is connected.
function wifiIcon(strength) {
    var icons = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"];
    if (strength < 0)
        return icons[4];
    return icons[Math.max(0, Math.min(4, Math.ceil(strength / 20) - 1))];
}

// A restricted link (captive portal, limited access) gets the crossed icon.
function icon(kind, strength, restricted) {
    if (kind === "wifi")
        return restricted ? "󰤩" : wifiIcon(strength);
    if (kind === "ethernet")
        return restricted ? "󰈂" : "󰈀";
    return "󰤮";
}

// NetworkManager reports link speed in Mb/s: 1000 -> "1gbit", 2500 -> "2.5gbit".
function formatSpeed(mbps) {
    var v = parseInt(mbps, 10);
    if (!v || v < 0)
        return "";
    if (v >= 1000)
        return (v / 1000).toFixed(v % 1000 === 0 ? 0 : 1) + "gbit";
    return v + "mbit";
}

// One list row per network, as plain values. A row never holds the live
// WifiNetwork: NetworkManager can drop that object while a row is still
// on screen, and omarchy saw quickshell crash on the dangling reference.
// NetState finds the live object again by name when it has to act.
// `security` maps the enum values this needs, since a .js file sees no
// QML types: {open, owe, enterprise: [...]}.
function wifiRow(network, security) {
    var s = network.security;
    return {
        ssid: network.name || "",
        // Rounded to the step the icon shows, so a signal wobbling by a few
        // percent does not rebuild the list under the pointer.
        signal: Math.ceil(Math.round((network.signalStrength || 0) * 100) / 20) * 20,
        connected: !!network.connected,
        known: !!network.known,
        secured: s !== security.open && s !== security.owe,
        enterprise: security.enterprise.indexOf(s) >= 0
    };
}

// Connected first, then saved networks, then the strongest signal.
function sortRows(rows) {
    return rows.slice().sort(function (a, b) {
        if (a.connected !== b.connected)
            return a.connected ? -1 : 1;
        if (a.known !== b.known)
            return a.known ? -1 : 1;
        return b.signal - a.signal;
    });
}

// Gives the first row of each group its heading, and every other row "".
// Rows are sorted known first, so there are at most two headings.
function withHeadings(rows) {
    var previous = "";
    return rows.map(function (row) {
        var group = row.known ? "KNOWN NETWORKS" : "OTHER NETWORKS";
        row.heading = group !== previous ? group : "";
        previous = group;
        return row;
    });
}

// Forgetting the network in use would drop the connection as a side
// effect; disconnect first, then forget.
function canForget(row) {
    return row.known && !row.connected;
}

// What a failed connect says on its row. `reasons` maps the
// ConnectionFailReason values, like `security` above.
function failureText(reason, secured, reasons) {
    if (secured && reason === reasons.noSecrets)
        return "Password required";
    if (secured && reason === reasons.authTimeout)
        return "Wrong password";
    if (reason === reasons.networkLost)
        return "Network lost";
    if (reason === reasons.clientDisconnected)
        return "Disconnected";
    return "Failed to connect";
}

// A missing or rejected password reopens the prompt, so it can be typed
// again; connectWithPsk replaces whatever was saved.
function shouldAskPassword(reason, secured, reasons) {
    return secured && (reason === reasons.noSecrets || reason === reasons.authTimeout);
}
