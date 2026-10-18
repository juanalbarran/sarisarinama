// quickshell/panes/audio/audiomodel.js
// Pure functions over Quickshell's PipeWire nodes, so AudioState only
// wires them to QML. Lists are walked by index: Pipewire.nodes.values is a
// Qt list, and not every Array method is promised on it.

function pick(list, keep) {
    var result = [];
    var values = list && list.length ? list : [];
    for (var i = 0; i < values.length; i++)
        if (values[i] && keep(values[i]))
            result.push(values[i]);
    return result;
}

// Hardware outputs and inputs, and the apps playing: a playback stream is
// a stream that takes audio in, so it reports isSink, as omarchy found.
function isOutput(node) {
    return !!node.audio && node.isSink && !node.isStream;
}

function isInput(node) {
    return !!node.audio && !node.isSink && !node.isStream;
}

function isApp(node) {
    return !!node.audio && node.isSink && node.isStream;
}

// What a Repeater is given: primitives, never the node. PipeWire deletes
// a node outright, and a row still holding it is a dangling QObject that
// crashes the shell. The name rides along because PipeWire reuses ids.
function rows(nodes) {
    return nodes.map(n => ({
                id: n.id,
                name: String(n.name || "")
            }));
}

function sameRows(a, b) {
    return JSON.stringify(a) === JSON.stringify(b);
}

// A node's properties are only valid once it is bound (tracked).
function props(node) {
    return node && node.ready && node.properties ? node.properties : {};
}

function deviceLabel(node) {
    if (!node)
        return "Unknown";
    return node.description || node.nickname || node.name || "Unknown";
}

function appLabel(node) {
    if (!node)
        return "App";
    var p = props(node);
    return p["application.name"] || node.description || p["media.name"] || node.name || "App";
}

function blob(node) {
    var p = props(node);
    return [node.name, node.description, node.nickname, p["device.icon-name"] || ""].join(" ").toLowerCase();
}

function outputGlyph(node) {
    var b = node ? blob(node) : "";
    if (/headphone|headset|earbud|airpod/.test(b))
        return "󰋋";
    if (/bluez|bluetooth/.test(b))
        return "󰂯";
    if (/hdmi|displayport/.test(b))
        return "󰍹";
    return "󰓃";
}

function inputGlyph(node) {
    var b = node ? blob(node) : "";
    if (/headset/.test(b))
        return "󰋋";
    if (/bluez|bluetooth/.test(b))
        return "󰂯";
    if (/webcam|camera/.test(b))
        return "󰄀";
    return "󰍬";
}

// The bar's speaker glyphs: muted, then three levels.
function volumeIcon(volume, muted) {
    if (muted)
        return "󰝟";
    return volume > 0.66 ? "" : volume > 0.33 ? "" : "";
}

function micIcon(muted) {
    return muted ? "󰍭" : "󰍬";
}

function percent(volume) {
    return Math.round(volume * 100) + "%";
}
