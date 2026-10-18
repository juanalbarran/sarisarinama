// quickshell/panes/battery/Cursor.qml
// The battery panel's cursor: a LineCursor with one line, the profile
// pills, a stop each. h and l move between them, Enter applies the one
// under the cursor.
import QtQuick
import "../common/"

LineCursor {
    id: root

    required property BatteryState battery

    lines: [
        {
            id: "profile",
            stops: root.battery.profiles.length
        }
    ]

    // Arriving on the row lands on the profile in force.
    firstStop: id => Math.max(0, root.battery.profiles.findIndex(p => p.id === root.battery.profile))

    onActivated: (line, stop) => root.battery.setProfile(root.battery.profiles[stop].id)
}
