// quickshell/notifications/notifmodel.js
// What the notification centre decides, with no QML in it: how long a toast
// stays, what Do Not Disturb lets through, a notification turned into a plain
// row, and the words the panel shows. After omarchy quattro's Delivery.js and
// Store.js. Kept pure so it can be tested headless.
.pragma library

// NotificationUrgency's values.
var LOW = 0;
var NORMAL = 1;
var CRITICAL = 2;

// omarchy's: a toast stays at least 5 s (low) or 8 s (normal), stretched up
// to 30 s when the sender asks for longer; a critical one waits for you (0).
var LOW_MS = 5000;
var NORMAL_MS = 8000;
var MAX_MS = 30000;

// How many closed notifications the panel keeps.
var HISTORY_MAX = 100;

function durationFor(urgency, requested) {
    if (urgency === CRITICAL)
        return 0;
    var base = urgency === LOW ? LOW_MS : NORMAL_MS;
    var asked = Number(requested);
    return Math.min(MAX_MS, Math.max(base, isFinite(asked) && asked > 0 ? asked : 0));
}

// A bare `notify-send -u critical` is an emergency and gets through Do Not
// Disturb. Critical alone is not enough: chat apps send critical to force
// themselves on screen, under their own app name.
function bypassesQuiet(row) {
    return row.app === "notify-send" && row.urgency === CRITICAL;
}

// Nobody looks back at these (the `transient` hint, or a bare notify-send),
// so while quiet they are dropped rather than kept in the history.
function isEphemeral(row) {
    return row.transient === true || row.app === "notify-send";
}

// "show", "keep" (straight to the history, not on screen) or "drop".
function admit(row, dnd) {
    if (!dnd || bypassesQuiet(row))
        return "show";
    return isEphemeral(row) ? "drop" : "keep";
}

// Senders send markup even to a server that does not ask for it; the shell
// draws plain text, so tags go and entities are read.
function plainText(s) {
    return String(s || "").replace(/<br\s*\/?>/gi, "\n").replace(/<[^>]*>/g, "").replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, "\"").replace(/&#39;|&apos;/g, "'").replace(/&amp;/g, "&").trim();
}

// The notification's picture: a sender's image ("image://qsimage/…" for one
// sent as data, or a file), "" for none. `-i name` arrives as
// "image://icon/name", a theme icon's name rather than a picture.
function imageSource(image) {
    var s = String(image || "");
    if (s.indexOf("image://icon/") === 0)
        return "";
    if (s.indexOf("image://") === 0 || s.indexOf("file://") === 0)
        return s;
    return s.charAt(0) === "/" ? "file://" + s : "";
}

// The theme icon's name to look up: the app's icon, else the name `-i` gave,
// else the desktop entry, which usually names the app's icon too.
function iconName(appIcon, image, desktopEntry) {
    var s = String(image || "");
    var named = s.indexOf("image://icon/") === 0 ? s.slice("image://icon/".length) : "";
    return String(appIcon || named || desktopEntry || "");
}

// The letter drawn when there is no picture and no icon.
function initial(row) {
    var s = String(row.app || row.summary || "?").trim();
    return s === "" ? "?" : s.charAt(0).toUpperCase();
}

// A Notification as a plain row, so nothing that draws it holds the live
// object, which the sender may close at any time. `actions` keeps only what
// a button needs; "default" is the card's own click, not a button.
function snapshot(n, key, now) {
    var actions = [];
    var hasDefault = false;
    (n.actions || []).forEach(a => {
        if (a.identifier === "default")
            hasDefault = true;
        else
            actions.push({
                id: String(a.identifier),
                text: String(a.text || a.identifier)
            });
    });
    var hints = n.hints || {};
    var urgency = Number(n.urgency);
    return {
        key: key,
        app: String(n.appName || ""),
        summary: plainText(n.summary),
        body: plainText(n.body),
        urgency: urgency === LOW || urgency === CRITICAL ? urgency : NORMAL,
        image: imageSource(n.image),
        icon: iconName(n.appIcon, n.image, n.desktopEntry),
        transient: n.transient === true || hints.transient === true || hints.transient === 1,
        actions: JSON.stringify(actions),
        hasDefault: hasDefault,
        duration: durationFor(Number(n.urgency), n.expireTimeout),
        ts: now
    };
}

// The history after `row` arrives: newest first, one entry per key (an
// update replaces its entry), at most HISTORY_MAX.
function remember(history, row) {
    return [row].concat(history.filter(h => h.key !== row.key)).slice(0, HISTORY_MAX);
}

// "now", minutes, then the clock time, then the day.
function ago(ts, now) {
    var s = Math.max(0, (now - ts) / 1000);
    if (s < 60)
        return "now";
    if (s < 3600)
        return Math.floor(s / 60) + "m";
    var then = new Date(ts);
    var today = new Date(now);
    var pad = n => (n < 10 ? "0" : "") + n;
    if (then.toDateString() === today.toDateString())
        return pad(then.getHours()) + ":" + pad(then.getMinutes());
    return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][then.getDay()];
}
