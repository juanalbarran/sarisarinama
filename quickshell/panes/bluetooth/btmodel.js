// quickshell/panes/bluetooth/btmodel.js
// What the Bluetooth panel computes from BlueZ's devices, with no QML in it:
// a device as a plain row, the rows sorted into sections, a device's glyph
// and the words under its name. After omarchy quattro's bluetooth Model.js.
// Kept pure so it can be tested headless.
.pragma library

// BluetoothDeviceState's values.
var DISCONNECTED = 0;
var CONNECTED = 1;
var DISCONNECTING = 2;
var CONNECTING = 3;

function isUuidLike(s) {
    return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(s) || /^[0-9a-f]{32}$/i.test(s) || /^0x[0-9a-f]{4,32}$/i.test(s);
}

function isAddressLike(s) {
    return /^([0-9a-f]{2}[:-]){5}[0-9a-f]{2}$/i.test(s);
}

// The name to show: what the user called it, else what it calls itself.
function label(d) {
    return String(d.name || d.deviceName || "").trim();
}

// Nearby devices that announce only an address or a UUID are noise.
function hasHumanName(d) {
    var s = label(d);
    return s !== "" && !isUuidLike(s) && !isAddressLike(s);
}

// A BluetoothDevice as plain values. A row never holds the device itself:
// BlueZ can drop one (a scan timing out, a forget) while a delegate still
// holds it, which crashes the shell, as omarchy found. Actions go by address.
function snapshot(devices) {
    var rows = [];
    (devices || []).forEach(d => {
        if (!d || !hasHumanName(d))
            return;
        rows.push({
            address: String(d.address || ""),
            name: label(d),
            icon: String(d.icon || ""),
            connected: d.connected === true,
            known: d.paired === true || d.bonded === true || d.trusted === true,
            pairing: d.pairing === true,
            state: Number(d.state),
            battery: d.batteryAvailable ? Math.round(Number(d.battery) * 100) : -1
        });
    });
    return rows;
}

// Connected, then paired, then what a scan found (only while scanning),
// each by name. The first row of a section carries its heading.
function rows(snap, discovering) {
    var byName = (a, b) => a.name.localeCompare(b.name);
    var sections = [["CONNECTED", snap.filter(r => r.connected)], ["PAIRED", snap.filter(r => !r.connected && r.known)], ["AVAILABLE", discovering ? snap.filter(r => !r.connected && !r.known) : []]];
    var out = [];
    sections.forEach(([heading, list]) => {
        list.sort(byName).forEach((r, i) => {
            var row = Object.assign({}, r);
            row.heading = i === 0 ? heading : "";
            out.push(row);
        });
    });
    return out;
}

// What a click on the row does.
function actionFor(row) {
    if (row.connected)
        return "disconnect";
    return row.known ? "connect" : "pair";
}

// Forget is for what BlueZ remembers.
function canForget(row) {
    return row.known || row.connected;
}

// The device's kind, from BlueZ's icon name, as a Nerd Font glyph.
function glyph(icon) {
    var s = String(icon || "");
    if (s.startsWith("audio-head"))
        return "󰋋";
    if (s.startsWith("audio") || s === "multimedia-player")
        return "󰓃";
    if (s === "input-keyboard")
        return "󰌌";
    if (s === "input-mouse" || s === "input-tablet")
        return "󰍽";
    if (s === "input-gaming")
        return "󰊴";
    if (s === "phone")
        return "󰏲";
    if (s === "computer")
        return "󰟀";
    return "󰂯";
}

// The radio's glyph for the bar and the hero.
function radioGlyph(available, on, anyConnected) {
    if (!available || !on)
        return "󰂲";
    return anyConnected ? "󰂱" : "󰂯";
}

// The words under a device's name. `busy` is the action running on it, if
// any; `failed` the action that last failed on it.
function status(row, busy, failed) {
    if (busy)
        return ({
                pair: "Pairing…",
                connect: "Connecting…",
                disconnect: "Disconnecting…",
                forget: "Forgetting…"
            })[busy] || "";
    if (failed)
        return ({
                pair: "Could not pair",
                connect: "Could not connect",
                disconnect: "Could not disconnect",
                forget: "Could not forget"
            })[failed] || "";
    if (row.state === DISCONNECTING)
        return "Disconnecting…";
    if (row.state === CONNECTING || row.pairing)
        return "Connecting…";
    if (row.connected)
        return row.battery >= 0 ? "Connected · " + row.battery + "%" : "Connected";
    return "";
}
