// quickshell/panes/battery/Stats.qml
// The numbers under the charge bar, one label and its value per row.
// UPower has no cycle count, so health stands where omarchy shows cycles;
// a battery that does not report health shows "--".
import QtQuick
import QtQuick.Layouts
import "../../theme/"
import "batmodel.js" as BatModel

GridLayout {
    id: root

    required property BatteryState battery

    readonly property var device: battery.device

    visible: battery.present
    columns: 2
    columnSpacing: Style.battery.row.gap
    rowSpacing: Style.battery.list.spacing

    component StatLabel: Text {
        color: Colors.battery.muted
        font.family: Style.battery.font.family
        font.pixelSize: Style.battery.font.body
    }

    // Values fill the rest of the row against its right edge, so the
    // numbers line up under each other.
    component StatValue: Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideLeft
        color: Colors.battery.text
        font.family: Style.battery.font.family
        font.pixelSize: Style.battery.font.body
    }

    StatLabel {
        text: "Capacity"
    }
    StatValue {
        text: BatModel.wattHours(root.device.energyCapacity)
    }

    StatLabel {
        text: "Health"
    }
    StatValue {
        text: root.device.healthSupported ? Math.round(root.device.healthPercentage) + "%" : "--"
    }

    StatLabel {
        text: root.battery.timeLabel
    }
    StatValue {
        text: root.battery.time
    }

    StatLabel {
        text: root.battery.onBattery ? "Draw" : "Charge rate"
    }
    StatValue {
        text: BatModel.watts(root.device.changeRate)
    }
}
