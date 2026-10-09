// quickshell/panes/network/statsmodel.js
// Plain functions for the network stats: reading a sample from
// sarisarinama-network-status, turning byte counters into rates, and
// averaging pings. Ported from omarchy's Model.js.

// "key<TAB>value" lines into {key: value}. An empty value stays "".
function parseSample(text) {
    var sample = {};
    var lines = String(text || "").split("\n");
    for (var i = 0; i < lines.length; i++) {
        var tab = lines[i].indexOf("\t");
        if (tab > 0)
            sample[lines[i].substring(0, tab)] = lines[i].substring(tab + 1).trim();
    }
    return sample;
}

// Bytes per second between two samples of the same interface. The first
// sample, or the first after a change of interface, has nothing to compare
// with and gives 0 rather than a spike. `now` is in seconds.
function rates(previous, sample, now) {
    var rx = parseFloat(sample.rx_bytes || "0");
    var tx = parseFloat(sample.tx_bytes || "0");
    var next = {
        iface: sample.iface || "",
        rx: rx,
        tx: tx,
        time: now,
        download: 0,
        upload: 0
    };
    if (!previous || previous.iface !== next.iface || !previous.time)
        return next;
    var dt = now - previous.time;
    if (dt > 0) {
        next.download = Math.max(0, (rx - previous.rx) / dt);
        next.upload = Math.max(0, (tx - previous.tx) / dt);
    }
    return next;
}

// The newest `limit` pings, oldest first. A ping with no answer is null.
function addPing(pings, raw, limit) {
    var value = parseFloat(raw);
    var next = pings.concat([isFinite(value) && value >= 0 ? value : null]);
    return next.slice(Math.max(0, next.length - limit));
}

// Mean of the answered pings among the newest `count`; -1 when none answered.
function averagePing(pings, count) {
    var total = 0;
    var answered = 0;
    for (var i = Math.max(0, pings.length - count); i < pings.length; i++) {
        if (pings[i] !== null) {
            total += pings[i];
            answered++;
        }
    }
    return answered > 0 ? total / answered : -1;
}

// Share of pings that got no answer, as a whole percent.
function packetLoss(pings) {
    if (pings.length === 0)
        return 0;
    var lost = pings.filter(p => p === null).length;
    return Math.round(lost / pings.length * 100);
}

function formatBytes(bytes) {
    var n = Number(bytes);
    if (!isFinite(n) || n < 0)
        n = 0;
    if (n < 1024)
        return Math.round(n) + " B";
    if (n < 1024 * 1024)
        return (n / 1024).toFixed(1) + " KB";
    if (n < 1024 * 1024 * 1024)
        return (n / (1024 * 1024)).toFixed(1) + " MB";
    return (n / (1024 * 1024 * 1024)).toFixed(2) + " GB";
}

function formatRate(bytesPerSecond) {
    return formatBytes(bytesPerSecond) + "/s";
}

// "--" until a ping has come back at all; "Timeout" when none answered.
function formatPing(ms, hasPings) {
    if (!hasPings)
        return "--";
    if (ms < 0)
        return "Timeout";
    return ms.toFixed(ms > 0 && ms < 10 ? 1 : 0) + " ms";
}

function formatLoss(percent, hasPings) {
    return hasPings ? percent + "%" : "--";
}
