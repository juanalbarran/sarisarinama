// quickshell/notifications/NotificationCenter.qml
// The notification daemon: Quickshell's NotificationServer owns
// org.freedesktop.Notifications while notifications.json says `enable`, so
// notify-send and every libnotify app land here. It keeps the toasts on
// screen, the history the panel lists and Do Not Disturb, and answers the
// `notifications` IPC target. After omarchy quattro's notifications
// Service.qml, see docs/notifications.md.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "../theme/"
import "notifmodel.js" as NotifModel

Singleton {
    id: root

    readonly property ConfigFile file: ConfigFile {
        name: "notifications"
    }

    // Off unless the config turns it on: only one daemon can own the bus
    // name, and another one (dunst, mako) may have it.
    readonly property bool enabled: root.file.value("enable", false) === true

    property bool dnd: false

    // On screen, newest first: plain rows, see NotifModel.snapshot. A
    // ListModel, so a new toast does not rebuild the others and restart
    // their countdowns.
    readonly property ListModel toasts: ListModel {}

    // Every notification shown or held back this session, newest first.
    property var history: []
    // Arrived since the panel last showed them.
    property int unread: 0

    // key -> the live Notification. A plain map, never a model role: the
    // object is gone once the sender closes it, and a role would dangle.
    property var refs: ({})
    property int serial: 0

    LazyLoader {
        active: root.enabled

        NotificationServer {
            keepOnReload: false
            bodySupported: true
            // Drawn as plain text; markup a sender sends anyway is stripped.
            bodyMarkupSupported: false
            actionsSupported: true
            imageSupported: true
            persistenceSupported: true

            onNotification: n => root.receive(n)
        }
    }

    function receive(n) {
        var key = "n" + (++root.serial);
        // Otherwise the object is destroyed when this handler returns.
        n.tracked = true;
        var row = NotifModel.snapshot(n, key, Date.now());
        var verdict = NotifModel.admit(row, root.dnd);
        if (verdict === "drop") {
            n.tracked = false;
            return;
        }
        root.history = NotifModel.remember(root.history, row);
        root.unread += 1;
        if (verdict === "keep") {
            n.tracked = false;
            return;
        }
        row.revision = 0;
        root.refs[key] = n;
        root.watch(n, key);
        // Inserting while a Repeater builds a delegate can crash Qt.
        Qt.callLater(() => {
            if (root.refs[key] === n)
                root.toasts.insert(0, row);
        });
    }

    // The sender may close its notification, or update it in place
    // (replaces_id), which changes this object rather than sending a new
    // one. An update is taken once its burst of property changes settles.
    function watch(n, key) {
        n.closed.connect(() => {
            if (root.refs[key] !== n)
                return;
            delete root.refs[key];
            root.remove(key);
        });
        var queued = false;
        var refresh = () => {
            queued = false;
            if (root.refs[key] === n)
                root.update(key, NotifModel.snapshot(n, key, Date.now()));
        };
        var schedule = () => {
            if (!queued) {
                queued = true;
                Qt.callLater(refresh);
            }
        };
        [n.summaryChanged, n.bodyChanged, n.appNameChanged, n.appIconChanged, n.imageChanged, n.urgencyChanged, n.expireTimeoutChanged, n.actionsChanged].forEach(s => s.connect(schedule));
    }

    function indexOf(key) {
        for (var i = 0; i < root.toasts.count; i++)
            if (root.toasts.get(i).key === key)
                return i;
        return -1;
    }

    // An update keeps the toast where it is; its new revision restarts the
    // countdown.
    function update(key, row) {
        root.history = root.history.map(h => h.key === key ? row : h);
        var i = root.indexOf(key);
        if (i < 0)
            return;
        row.revision = root.toasts.get(i).revision + 1;
        root.toasts.set(i, row);
    }

    function remove(key) {
        var i = root.indexOf(key);
        if (i >= 0)
            root.toasts.remove(i);
    }

    function isShown(key) {
        return root.refs[key] !== undefined;
    }

    // Lets the sender's object go, telling it why: "expired" or "dismissed".
    // The reference goes first, so the close signal finds nothing to do.
    function release(key, reason) {
        var n = root.refs[key];
        delete root.refs[key];
        root.remove(key);
        if (!n)
            return;
        if (reason === "expired")
            n.expire();
        else
            n.dismiss();
    }

    function expire(key) {
        root.release(key, "expired");
    }

    function dismiss(key) {
        root.release(key, "dismissed");
    }

    // A button: the sender's action, then the toast goes.
    function invoke(key, id) {
        var n = root.refs[key];
        if (n)
            (n.actions || []).forEach(a => {
                if (a.identifier === id)
                    a.invoke();
            });
        if (root.refs[key])
            root.dismiss(key);
    }

    // A click on the card: the sender's default action when it has one.
    function activate(key) {
        root.invoke(key, "default");
    }

    function dismissNewest() {
        if (root.toasts.count === 0)
            return false;
        root.dismiss(root.toasts.get(0).key);
        return true;
    }

    function dismissAll() {
        var keys = [];
        for (var i = 0; i < root.toasts.count; i++)
            keys.push(root.toasts.get(i).key);
        keys.forEach(k => root.dismiss(k));
        return keys.length;
    }

    function forget(key) {
        if (root.isShown(key))
            root.dismiss(key);
        root.history = root.history.filter(h => h.key !== key);
    }

    function clearHistory() {
        root.history = [];
        root.unread = 0;
    }

    function markRead() {
        root.unread = 0;
    }

    function setDnd(on) {
        root.dnd = on;
    }

    IpcHandler {
        target: "notifications"

        function dndState(): string {
            return root.dnd ? "on" : "off";
        }

        function toggleDnd(): string {
            root.setDnd(!root.dnd);
            return root.dnd ? "on" : "off";
        }

        function setDnd(state: string): string {
            if (state !== "on" && state !== "off")
                return "usage: setDnd on|off";
            root.setDnd(state === "on");
            return state;
        }

        function dismissOne(): string {
            return root.dismissNewest() ? "ok" : "none";
        }

        function dismissAll(): string {
            return String(root.dismissAll());
        }

        function invokeLast(): string {
            if (root.toasts.count === 0)
                return "none";
            root.activate(root.toasts.get(0).key);
            return "ok";
        }

        function count(): string {
            return String(root.toasts.count);
        }

        function clear(): string {
            root.clearHistory();
            return "ok";
        }
    }
}
