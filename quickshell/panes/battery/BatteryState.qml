// quickshell/panes/battery/BatteryState.qml
// What UPower and power-profiles-daemon say about the battery, and the one
// change the panel can make: the power profile. Unlike VpnState nothing is
// polled: both are D-Bus services Quickshell listens to, so every property
// here follows them on its own.
import QtQuick
import Quickshell.Services.UPower
import "batmodel.js" as BatModel

QtObject {
    id: root

    readonly property var device: UPower.displayDevice
    // The same test as the bar's widget: a desktop has no panel to show.
    readonly property bool present: !!(device && device.isLaptopBattery)
    readonly property real fraction: present ? Math.max(0, Math.min(1, device.percentage)) : 0
    readonly property bool onBattery: UPower.onBattery
    readonly property bool charging: present && device.state === UPowerDeviceState.Charging
    // The bar's rule: 15% or less, and not plugged in.
    readonly property bool low: present && onBattery && fraction <= 0.15

    readonly property string icon: BatModel.icon(fraction, !onBattery)

    readonly property string status: {
        if (!present)
            return "No battery";
        switch (device.state) {
        case UPowerDeviceState.FullyCharged:
            return "Fully charged";
        case UPowerDeviceState.PendingCharge:
            // Plugged in but not charging: a charge threshold holds it.
            return "Holding charge";
        case UPowerDeviceState.Charging:
            return "Charging";
        }
        return onBattery ? "On battery" : "Plugged in";
    }

    // Which way the time runs: down to empty on battery, up to full while
    // charging, and nowhere when it sits still.
    readonly property string timeLabel: onBattery ? "Time left" : "Time to full"
    readonly property string time: {
        if (!present)
            return "--";
        if (onBattery)
            return BatModel.duration(device.timeToEmpty);
        return charging ? BatModel.duration(device.timeToFull) : "--";
    }

    readonly property var profiles: BatModel.profiles(PowerProfiles.hasPerformanceProfile)
    readonly property string profile: {
        var p = PowerProfiles.profile;
        if (p === PowerProfile.PowerSaver)
            return "power-saver";
        return p === PowerProfile.Performance ? "performance" : "balanced";
    }
    // Why performance is being held back (heat, a lap), or "".
    readonly property string degraded: PowerProfiles.degradationReason === PerformanceDegradationReason.None ? "" : PerformanceDegradationReason.toString(PowerProfiles.degradationReason)

    function setProfile(id) {
        if (id === "power-saver")
            PowerProfiles.profile = PowerProfile.PowerSaver;
        else if (id === "performance")
            PowerProfiles.profile = PowerProfile.Performance;
        else
            PowerProfiles.profile = PowerProfile.Balanced;
    }
}
