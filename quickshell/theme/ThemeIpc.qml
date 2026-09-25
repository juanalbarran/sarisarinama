// quickshell/theme/ThemeIpc.qml
// `qs ipc call theme ...`: read, list and switch the theme at runtime.
// The only writer of current.json. Colors watches that file, so the whole
// UI follows a successful set without a rebuild — see docs/themes.md.
// IpcHandler exports every declared property, and `var` cannot cross IPC,
// so the theme list is a function, not a property.
import QtQuick
import Quickshell.Io

IpcHandler {
    id: root

    target: "theme"

    // A ConfigFile loads on first access, so an IPC call that is itself the
    // first access would answer from the defaults. Touch Colors at startup.
    Component.onCompleted: Colors.themeName

    // Nix renders the list into theme.json; the shell never scans a
    // directory, so a name it accepts is always one that was rendered.
    function available() {
        return Colors.themeFile.value("available", []);
    }

    function get(): string {
        return Colors.themeName;
    }

    function list(): string {
        return root.available().join("\n");
    }

    function set(name: string): string {
        if (root.available().indexOf(name) < 0)
            return "unknown theme: " + name;
        // In memory first, so the UI switches now; the file is only how
        // the choice survives a restart, and the write is asynchronous.
        Colors.selected = name;
        Colors.currentFile.setText(JSON.stringify({
            default: name
        }) + "\n");
        return "ok";
    }
}
