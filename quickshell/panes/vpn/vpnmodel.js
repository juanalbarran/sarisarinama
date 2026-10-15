// quickshell/panes/vpn/vpnmodel.js
// Pure functions over `nmcli -t -f NAME,UUID,TYPE,STATE connection show`,
// so VpnState only wires them to QML.

// What NetworkManager calls a VPN: a plugin VPN (OpenVPN, OpenConnect…)
// has type "vpn", a WireGuard tunnel "wireguard".
var vpnTypes = ["vpn", "wireguard"];

// One terse line, split on the colons nmcli did not escape. A name may
// hold a colon; nmcli writes it as "\:" and a backslash as "\\".
function splitTerse(line) {
    var fields = [];
    var current = "";
    for (var i = 0; i < line.length; i++) {
        var c = line[i];
        if (c === "\\" && i + 1 < line.length) {
            current += line[++i];
        } else if (c === ":") {
            fields.push(current);
            current = "";
        } else {
            current += c;
        }
    }
    fields.push(current);
    return fields;
}

// The VPN profiles, [{name, uuid, type, state}], connected first, then by
// name. state is "", "activating", "activated" or "deactivating".
function parse(text) {
    return text.split("\n").filter(l => l !== "").map(l => {
        var f = splitTerse(l);
        return {
            name: f[0],
            uuid: f[1],
            type: f[2],
            state: f[3] || ""
        };
    }).filter(p => vpnTypes.indexOf(p.type) >= 0).sort((a, b) => (b.state === "activated") - (a.state === "activated") || a.name.localeCompare(b.name));
}

// Up, or on its way up: what the row's switch shows.
function isUp(profile) {
    return profile.state === "activated" || profile.state === "activating";
}

function typeLabel(profile) {
    return profile.type === "wireguard" ? "WireGuard" : "VPN";
}

function icon(connected) {
    return "󰖂";
}

// nmcli's first error line, without its "Error: " prefix.
function errorText(stderr) {
    var line = stderr.trim().split("\n")[0] || "";
    return line.replace(/^Error:\s*/, "") || "Could not change it";
}
