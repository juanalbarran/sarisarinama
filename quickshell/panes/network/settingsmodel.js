// quickshell/panes/network/settingsmodel.js
// Plain functions for the band and DNS rows: reading the scripts' status
// into values, and naming what is in force.

// "5 6" -> ["5", "6"]; "" -> [].
function words(text) {
    return String(text || "").split(" ").filter(w => w !== "");
}

// A band status, {band, available, selected}, or {} with no Wi-Fi.
function bandStatus(sample) {
    if (sample.selected === undefined)
        return {};
    return {
        band: sample.band || "",
        available: words(sample.available),
        selected: sample.selected
    };
}

// A DNS status, {profile, auto, servers}, or {} with no connection.
function dnsStatus(sample) {
    if (sample.profile === undefined)
        return {};
    return {
        profile: sample.profile,
        auto: sample.auto === "yes",
        servers: words(sample.servers)
    };
}

// Auto first, then each band the network answers on.
function bandOptions(status) {
    return status.available ? ["auto"].concat(status.available) : [];
}

function bandLabel(band) {
    return band === "auto" ? "Auto" : band + " GHz";
}

// Worth a row when there is a choice, or when a pin is in force: then Auto
// must stay reachable, or the pin could not be undone from the panel.
function bandWorthShowing(status) {
    return !!status.available && (status.available.length > 1 || status.selected !== "auto");
}

// The provider whose servers are in force: "DHCP" when the network's own
// are used, "" when they match none of the list.
function providerFor(status, providers) {
    if (status.auto)
        return "DHCP";
    var mine = (status.servers || []).slice().sort().join(" ");
    var match = providers.find(p => p.name !== "DHCP" && p.servers.slice().sort().join(" ") === mine);
    return match ? match.name : "";
}
