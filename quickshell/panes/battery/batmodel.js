// quickshell/panes/battery/batmodel.js
// Pure functions over what UPower and power-profiles-daemon report, so
// BatteryState only wires them to QML. A charge here is 0..1, as
// UPowerDevice.percentage gives it.

// nf-md-battery*, one per decile (0 = empty, 10 = full), as the bar's widget.
var dischargingIcons = ["\u{f008e}", "\u{f007a}", "\u{f007b}", "\u{f007c}", "\u{f007d}", "\u{f007e}", "\u{f007f}", "\u{f0080}", "\u{f0081}", "\u{f0082}", "\u{f0079}"];
// nf-md-battery_charging_*: the bolt inside the battery.
var chargingIcons = ["\u{f089c}", "\u{f089c}", "\u{f0086}", "\u{f0087}", "\u{f0088}", "\u{f089d}", "\u{f0089}", "\u{f089e}", "\u{f008a}", "\u{f008b}", "\u{f0085}"];

function icon(fraction, pluggedIn) {
    var i = Math.max(0, Math.min(10, Math.floor(fraction * 10)));
    return (pluggedIn ? chargingIcons : dischargingIcons)[i];
}

function percent(fraction) {
    return Math.round(fraction * 100) + "%";
}

// Seconds as "2h 05m" or "45m". UPower reports 0 while it is still
// estimating, which shows as "--" rather than "0m".
function duration(seconds) {
    if (!seconds || seconds <= 0)
        return "--";
    var minutes = Math.round(seconds / 60);
    var h = Math.floor(minutes / 60);
    var m = minutes % 60;
    return h > 0 ? h + "h " + (m < 10 ? "0" : "") + m + "m" : m + "m";
}

function watts(rate) {
    var w = Math.abs(rate || 0);
    return w > 0 ? w.toFixed(1) + " W" : "--";
}

function wattHours(energy) {
    return energy > 0 ? energy.toFixed(1) + " Wh" : "--";
}

// The profiles as pills, [{id, label}], in power order. Performance only
// where the hardware offers it.
function profiles(hasPerformance) {
    var list = [
        { id: "power-saver", label: "Power-saver" },
        { id: "balanced", label: "Balanced" }
    ];
    if (hasPerformance)
        list.push({ id: "performance", label: "Performance" });
    return list;
}
