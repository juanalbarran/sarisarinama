// quickshell/lock/LogindLock.qml
// logind's side of locking, through sarisarinama-lock-events: `lock` when
// `loginctl lock-session` runs, `sleep` when the machine is about to
// suspend. Suspend waits, up to 4 s, until release() says the lock is up;
// the script then exits and is started again for the next suspend.
import QtQuick
import Quickshell.Io

Item {
    id: root

    signal lockRequested
    signal sleepRequested

    // True from `sleep` until released or the script exits. Only then is a
    // line written: one left over would reach the next run's stdin and let
    // its suspend through before the lock is up.
    property bool waiting: false

    // Lets the suspend go ahead. Safe to call when nothing is waiting.
    function release() {
        if (!waiting)
            return;
        waiting = false;
        events.write("go\n");
    }

    Process {
        id: events
        command: ["sarisarinama-lock-events"]
        running: true
        stdinEnabled: true

        stdout: SplitParser {
            onRead: line => {
                if (line === "lock")
                    root.lockRequested();
                else if (line === "sleep") {
                    root.waiting = true;
                    root.sleepRequested();
                }
            }
        }

        // After every suspend, and after a failure (no logind, script not
        // on PATH): start again, not in a tight loop.
        onExited: {
            root.waiting = false;
            restart.start();
        }
    }

    Timer {
        id: restart
        interval: 3000
        onTriggered: events.running = true
    }
}
