// quickshell/panes/keybinds/keymodel.js
// What the keybinds pane computes from cheatsheets.json, with no QML in it:
// a bind's keys split into keycaps, the bind count and the columns. Kept
// pure so it can be tested headless.
.pragma library

// "Ctrl+b c" -> [["Ctrl", "b"], ["c"]]: chords pressed one after the
// other, each a list of keys held together. "Plus" is the key +.
function steps(keys) {
    return String(keys).trim().split(/\s+/).filter(s => s !== "").map(step => step === "+" ? ["+"] : step.split("+").filter(k => k !== "").map(k => k === "Plus" ? "+" : k));
}

// A key written {like this} is something to type, not a key: a motion,
// a character.
function isPlaceholder(key) {
    return key.length > 2 && key.charAt(0) === "{" && key.charAt(key.length - 1) === "}";
}

function placeholderText(key) {
    return key.slice(1, -1);
}

function count(groups) {
    return (groups || []).reduce((n, g) => n + (g.binds || []).length, 0);
}

// The groups split into `n` columns, in reading order: the first column
// is filled down to its share before the next one starts, so the groups
// read top to bottom, then left to right. A heading weighs two rows.
function columns(groups, n) {
    if (!groups || groups.length === 0)
        return [];
    var cols = [];
    for (var c = 0; c < n; c++)
        cols.push([]);
    var weight = g => g.binds.length + 2;
    var total = groups.reduce((s, g) => s + weight(g), 0);
    var target = total / n;
    var col = 0;
    var acc = 0;
    groups.forEach((g, i) => {
        var left = groups.length - i;
        // Move on when this group would overshoot the share by more than
        // half of itself, and never leave a later column with nothing.
        var full = cols[col].length > 0 && acc + weight(g) / 2 > target;
        if (col < n - 1 && (full || left <= n - 1 - col)) {
            col++;
            acc = 0;
        }
        cols[col].push(g);
        acc += weight(g);
    });
    return cols.filter(c => c.length > 0);
}
