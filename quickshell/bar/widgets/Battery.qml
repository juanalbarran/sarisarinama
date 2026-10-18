// quickshell/bar/widgets/Battery.qml
// After canaima's waybar battery: one bolt while charging, nine levels
// otherwise, yellow below `warning`, red and blinking below `critical`.
import Quickshell.Services.UPower
import QtQuick
import "../../theme/"

Text {
    id: root

    signal clicked

    readonly property var dev: UPower.displayDevice
    readonly property int pct: Math.round(dev.percentage * 100)
    readonly property bool charging: !UPower.onBattery

    // nf-md-battery_10 … battery_90, then battery (full); waybar's format-icons
    readonly property var icons: ["\u{f007a}", "\u{f007b}", "\u{f007c}", "\u{f007d}", "\u{f007f}", "\u{f0080}", "\u{f0081}", "\u{f0082}", "\u{f0079}"]
    // nf-md-battery_charging, whatever the level
    readonly property string chargingIcon: "\u{f0084}"

    // Waybar's ALabel::getIcon: integer steps of 100 / icons, clamped.
    readonly property string batIcon: charging ? chargingIcon : icons[Math.min(icons.length - 1, Math.floor(pct / Math.floor(100 / icons.length)))]

    // Waybar adds the state class whether or not it charges, and the CSS
    // lets critical win over warning, warning over charging.
    readonly property bool critical: pct <= Style.bar.battery.critical
    readonly property bool warning: pct <= Style.bar.battery.warning

    // 0 is urgent, 1 is text: the blink fades between them.
    property real blink: 0

    SequentialAnimation on blink {
        running: root.critical
        loops: Animation.Infinite
        onRunningChanged: if (!running) root.blink = 0
        NumberAnimation { to: 1; duration: Style.bar.battery.blink }
        NumberAnimation { to: 0; duration: Style.bar.battery.blink }
    }

    function mix(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, a.a + (b.a - a.a) * t);
    }

    visible: dev.isLaptopBattery
    text: batIcon + " " + pct + "%"
    color: critical ? mix(Colors.bar.urgent, Colors.bar.text, blink) : warning ? Colors.bar.warning : charging ? Colors.bar.charging : Colors.bar.text
    font.family: Style.bar.font.family
    font.pixelSize: Style.bar.textSize("battery", "body")

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
