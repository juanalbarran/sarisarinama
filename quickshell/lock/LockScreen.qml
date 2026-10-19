// quickshell/lock/LockScreen.qml
// The session lock. While locked the compositor shows only these surfaces,
// one per screen, and keeps showing them if the shell dies: ext-session-lock
// is released by an unlock, never by a crash. Always loaded, so `lock`
// answers over IPC whatever else is open, and so it hears the three
// triggers: `loginctl lock-session`, idle, and an imminent suspend.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root

    // True once every screen shows a lock surface: only then is it safe.
    readonly property bool secure: session.secure

    // Read afresh, never bound: setting `locked` from QML does not notify a
    // binding over it, so one would still say false while locked.
    function isLocked() {
        return session.locked;
    }

    property bool checking: false
    property string failure: ""
    // A suspend is held until the lock is secure.
    property bool holdingSleep: false

    // "missing-pam" when nothing could unlock it, and nothing is locked.
    function lock() {
        if (!auth.configured)
            return "missing-pam";
        if (!session.locked) {
            failure = "";
            session.locked = true;
        }
        return "ok";
    }

    function submit(password) {
        if (!session.locked || checking || password === "")
            return;
        checking = true;
        failure = "";
        auth.check(password);
    }

    // Locks before letting the suspend go; lets it go at once when locking
    // is impossible, rather than holding it for nothing.
    function lockForSleep() {
        if (root.lock() !== "ok" || session.secure) {
            logind.release();
            return;
        }
        holdingSleep = true;
    }

    IdleLock {
        onIdle: root.lock()
    }

    LogindLock {
        id: logind
        onLockRequested: root.lock()
        onSleepRequested: root.lockForSleep()
    }

    LockAuth {
        id: auth

        onSucceeded: {
            root.checking = false;
            session.locked = false;
        }

        onFailed: {
            root.checking = false;
            root.failure = "Wrong password";
        }
    }

    WlSessionLock {
        id: session

        onSecureStateChanged: {
            if (secure && root.holdingSleep) {
                root.holdingSleep = false;
                logind.release();
            }
        }

        WlSessionLockSurface {
            LockView {
                anchors.fill: parent
                checking: root.checking
                failure: root.failure
                onSubmitted: password => root.submit(password)
                onEdited: root.failure = ""
            }
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): string {
            return root.lock();
        }

        function status(): string {
            return JSON.stringify({
                locked: root.isLocked(),
                secure: root.secure,
                pam: auth.configured
            });
        }
    }
}
