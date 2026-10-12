// quickshell/panes/network/Cursor.qml
// The network panel's cursor: a LineCursor whose lines are the Wi-Fi
// switch, the band and DNS rows, then one per network. On a saved network
// the row is stop 0 and Forget stop 1. Beyond the shared keys, r rescans
// and w turns Wi-Fi on or off.
import QtQuick
import "../common/"
import "netmodel.js" as NetModel

LineCursor {
    id: root

    required property NetState net
    // Whether the network list is on screen; its rows are lines only then.
    property bool listShown: false
    // The band and DNS rows, and whether each is on screen.
    property NetSettings settings: null
    property bool bandShown: false
    property bool dnsShown: false

    // The password prompt has the keyboard while it is open.
    blocked: net.passwordSsid !== ""

    lines: {
        var result = [];
        if (net.canToggleWifi)
            result.push({
                id: "toggle",
                stops: 1
            });
        if (settings && bandShown)
            result.push({
                id: "band",
                stops: settings.bandOptions.length
            });
        if (settings && dnsShown)
            result.push({
                id: "dns",
                stops: settings.providers.length
            });
        if (listShown)
            for (var row of net.rows)
                result.push({
                    id: "wifi:" + row.ssid,
                    stops: NetModel.canForget(row) ? 2 : 1
                });
        return result;
    }

    // On opening: the first network, which is the connected one when there
    // is one; the switch when there is no list.
    startLine: lines => Math.max(0, lines.findIndex(l => l.id.startsWith("wifi:")))

    // Arriving on the band or DNS row lands on the choice in force, so
    // Enter there changes nothing until h or l moves away from it.
    firstStop: id => {
        if (id === "band")
            return Math.max(0, root.settings.bandOptions.indexOf(root.settings.bandSelected));
        if (id === "dns")
            return Math.max(0, root.settings.providers.findIndex(p => p.name === root.settings.dnsSelected));
        return 0;
    }

    onActivated: (line, stop) => {
        if (line === "toggle") {
            root.net.toggleWifi();
            return;
        }
        if (line === "band") {
            root.settings.setBand(root.settings.bandOptions[stop]);
            return;
        }
        if (line === "dns") {
            root.settings.setDns(root.settings.providers[stop].name);
            return;
        }
        var row = root.net.rows.find(r => "wifi:" + r.ssid === line);
        if (!row)
            return;
        if (stop === 1)
            root.net.forget(row);
        else
            root.net.activate(row);
    }

    onOtherKey: event => {
        if (event.key === Qt.Key_R)
            root.net.rescan();
        else if (event.key === Qt.Key_W)
            root.net.toggleWifi();
        else
            return;
        event.accepted = true;
    }
}
