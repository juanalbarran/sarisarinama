// quickshell/panes/monitor/monmodel.js
// Pure functions over the outputs Compositor hands back,
// [{name, description, active, focused, scale, width, height}], so
// MonState only wires them to QML.

// The built-in panel is eDP, LVDS or DSI: the same test as sarisarinama-lid.
function isInternal(name) {
    return /^(eDP|LVDS|DSI)-/.test(name);
}

// The laptop first, then the others in the compositor's order.
function sorted(outputs) {
    return outputs.filter(o => isInternal(o.name)).concat(outputs.filter(o => !isInternal(o.name)));
}

// The output the scale row acts on: the focused one, else the first that
// is on, else none.
function target(outputs) {
    return outputs.find(o => o.active && o.focused) || outputs.find(o => o.active) || null;
}

// How a scale is named and compared: "1.25" for 1.25, "2" for 2.0.
function scaleId(scale) {
    var n = Number(scale);
    return isFinite(n) && n > 0 ? String(Math.round(n * 100) / 100) : "";
}

function icon(output) {
    return isInternal(output.name) ? "󰌢" : "󰍹";
}

// "Laptop", else its make and model, else its connector.
function title(output) {
    if (isInternal(output.name))
        return "Laptop";
    return output.description || output.name;
}

// "HDMI-A-1 · 2560×1080 · 1.25×", or "HDMI-A-1 · Off".
function detail(output) {
    if (!output.active)
        return output.name + " · Off";
    return output.name + " · " + output.width + "×" + output.height + " · " + scaleId(output.scale) + "×";
}

function heroIcon(activeCount) {
    return activeCount > 1 ? "󰍺" : "󰍹";
}

// "2 ON", "1 OF 2 ON", or "READING…" until the compositor has answered.
function status(outputs, activeCount) {
    if (outputs.length === 0)
        return "READING…";
    if (activeCount === outputs.length)
        return activeCount + " ON";
    return activeCount + " OF " + outputs.length + " ON";
}
