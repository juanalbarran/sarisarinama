// quickshell/lock/LockAuth.qml
// Checks one password against PAM. `check(password)` starts a conversation
// and answers PAM's prompt with it; `succeeded` or `failed` ends it. The
// password is held only for the length of one conversation.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Item {
    id: root

    // The file in /etc/pam.d. Home Manager writes it off NixOS, the NixOS
    // module on NixOS; see modules/ui/lock/.
    property string service: "sarisarinama-lock"

    // PAM refuses a service with no file, so the lock checks this first:
    // locking with nothing able to unlock would strand the session.
    readonly property bool configured: pamFile.loaded
    readonly property bool busy: pam.active

    property string pending: ""

    signal succeeded
    signal failed

    function check(password) {
        if (busy || password === "")
            return;
        pending = password;
        if (!pam.start()) {
            pending = "";
            failed();
        }
    }

    function abort() {
        pending = "";
        if (pam.active)
            pam.abort();
    }

    // PAM may ask before or after start() returns; answer whichever way.
    function respond() {
        if (pam.active && pam.responseRequired && pending !== "") {
            pam.respond(pending);
            pending = "";
        }
    }

    PamContext {
        id: pam
        config: root.service
        user: Quickshell.env("USER")

        onResponseRequiredChanged: root.respond()
        onPamMessage: root.respond()

        onCompleted: function (result) {
            root.pending = "";
            if (result === PamResult.Success)
                root.succeeded();
            else
                root.failed();
        }

        onError: function (error) {
            root.pending = "";
            root.failed();
        }
    }

    FileView {
        id: pamFile
        property bool loaded: false
        path: "/etc/pam.d/" + root.service
        watchChanges: true
        printErrors: false
        onLoaded: loaded = true
        onLoadFailed: loaded = false
        onFileChanged: reload()
    }
}
