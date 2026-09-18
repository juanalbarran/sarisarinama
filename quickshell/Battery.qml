// quickshell/Battery.qml
import Quickshell.Services.UPower
import QtQuick

Text {
    readonly property var dev: UPower.displayDevice
    readonly property int pct: Math.round(dev.percentage * 100)
    readonly property bool charging: !UPower.onBattery

    // nf-md-battery* : index = pct decile (0 = empty, 10 = full)
    readonly property var dischargingIcons: ["\u{f008e}", "\u{f007a}", "\u{f007b}", "\u{f007c}", "\u{f007d}", "\u{f007e}", "\u{f007f}", "\u{f0080}", "\u{f0081}", "\u{f0082}", "\u{f0079}"]
    // nf-md-battery_charging_* : bolt inside the battery
    readonly property var chargingIcons: ["\u{f089c}", "\u{f089c}", "\u{f0086}", "\u{f0087}", "\u{f0088}", "\u{f089d}", "\u{f0089}", "\u{f089e}", "\u{f008a}", "\u{f008b}", "\u{f0085}"]

    readonly property string batIcon: (charging ? chargingIcons : dischargingIcons)[Math.min(10, Math.floor(pct / 10))]

    visible: dev.isLaptopBattery
    text: batIcon + " " + pct + "%"
    color: (pct <= 15 && !charging) ? Colors.urgent : Colors.text
    font.family: "JetBrains Mono Nerd Font"
    font.pixelSize: 12
}
