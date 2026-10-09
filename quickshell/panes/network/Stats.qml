// quickshell/panes/network/Stats.qml
// The stats under the hero row: one label and its value per row. Every
// cell is there from the first frame and reads "--" until its number
// arrives, so the panel does not jump when the first sample lands.
import QtQuick
import QtQuick.Layouts
import "../../theme/"
import "statsmodel.js" as StatsModel

GridLayout {
    id: root

    required property NetStats stats

    readonly property bool hasCounters: stats.sample.rx_bytes !== undefined
    readonly property bool lossy: stats.loss > 0

    visible: stats.connected
    columns: 2
    columnSpacing: Style.network.stats.columnGap
    rowSpacing: Style.network.stats.rowGap

    component StatLabel: Text {
        color: Colors.network.muted
        font.family: Style.network.font.family
        font.pixelSize: Style.network.stats.fontSize
    }

    // Values fill the rest of the row and sit against its right edge, so
    // the numbers line up under each other.
    component StatValue: Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideLeft
        color: Colors.network.text
        font.family: Style.network.font.family
        font.pixelSize: Style.network.stats.fontSize
    }

    StatLabel {
        text: "Ping"
    }
    StatValue {
        text: StatsModel.formatPing(root.stats.ping, root.stats.hasPings)
        color: root.lossy ? Colors.network.urgent : Colors.network.text
    }
    StatLabel {
        text: "Packet loss"
    }
    StatValue {
        text: StatsModel.formatLoss(root.stats.loss, root.stats.hasPings)
        color: root.lossy ? Colors.network.urgent : Colors.network.text
    }

    StatLabel {
        text: "Receiving"
    }
    StatValue {
        text: root.hasCounters ? StatsModel.formatRate(root.stats.download) : "--"
    }
    StatLabel {
        text: "Sending"
    }
    StatValue {
        text: root.hasCounters ? StatsModel.formatRate(root.stats.upload) : "--"
    }

    StatLabel {
        text: "Downloaded"
    }
    StatValue {
        text: root.hasCounters ? StatsModel.formatBytes(root.stats.sample.rx_bytes) : "--"
    }
    StatLabel {
        text: "Uploaded"
    }
    StatValue {
        text: root.hasCounters ? StatsModel.formatBytes(root.stats.sample.tx_bytes) : "--"
    }

    StatLabel {
        text: "IP address"
    }
    StatValue {
        text: root.stats.sample.ip || "--"
    }
    StatLabel {
        text: "Gateway"
    }
    StatValue {
        text: root.stats.sample.gateway || "--"
    }
}
