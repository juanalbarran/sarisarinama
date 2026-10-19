// quickshell/lock/IdleLock.qml
// Says when the session has gone `lock.idle` seconds without input. The
// compositor counts (ext-idle-notify), so it works on Sway and Hyprland
// alike, and an app inhibiting idle (a full-screen video) holds it off.
import QtQuick
import Quickshell.Wayland
import "../theme/"

Item {
    id: root

    signal idle

    ConfigFile {
        id: config
        name: "lock"
    }

    // 0 never locks on idle.
    readonly property int seconds: config.value("idle", 300)

    // An IdleMonitor keeps the timeout it started with and ignores a later
    // one (quickshell 0.3.0), and lock.json arrives after startup: so a new
    // timeout gets a new monitor.
    onSecondsChanged: {
        monitor.active = false;
        monitor.active = Qt.binding(() => root.seconds > 0);
    }

    Loader {
        id: monitor
        active: root.seconds > 0

        sourceComponent: IdleMonitor {
            timeout: root.seconds
            respectInhibitors: true
            onIsIdleChanged: {
                if (isIdle)
                    root.idle();
            }
        }
    }
}
