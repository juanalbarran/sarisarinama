// quickshell/theme/ThemeIpc.qml
// `qs ipc call theme ...`: read, list and switch the theme at runtime.
// The only writer of current.json. Colors watches that file, so the whole
// UI follows a successful set without a rebuild — see docs/themes.md.
// IpcHandler exports every declared property, and `var` cannot cross IPC,
// so the theme list is a function, not a property.
import QtQuick
import Quickshell
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

    // The themes menu: a JSON array of rows, the top level for "" and one
    // family's flavors otherwise. A theme's family is its name up to the
    // first dash, and a family of two or more is one row that reopens the
    // menu file a level down: catppuccin-latte and catppuccin-mocha under
    // catppuccin. A flavor is labelled by the rest of its name, and the one
    // named as the family by its mode. The helpers are local: every
    // function on an IpcHandler is exported, and an untyped one warns.
    function entries(family: string): string {
        var familyOf = name => name.split("-")[0];
        var members = group => root.available().filter(name => familyOf(name) === group);
        var shell = "qs -p '" + Quickshell.shellDir + "' ipc call theme set ";
        // `key` is what the menu counts the pick under: the action names
        // the store path, which every rebuild changes
        var row = (name, label) => ({
                    icon: "󰏘",
                    label: label,
                    action: shell + "'" + name + "'",
                    key: "theme " + name
                });
        if (family !== "")
            return JSON.stringify(members(family).map(name => row(name, name === family ? Colors.themeFile.value("modes", {})[name] || name : name.slice(family.length + 1))));
        var rows = [];
        root.available().forEach(name => {
            var group = familyOf(name);
            if (members(group).length < 2)
                rows.push(row(name, name));
            else if (!rows.some(r => r.arg === group))
                rows.push({
                    icon: "󰉋",
                    label: group,
                    menu: Quickshell.env("HOME") + "/.config/sarisarinama/themes.json",
                    arg: group
                });
        });
        return JSON.stringify(rows);
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
        // Applications outside the shell follow. Detached, so a slow one
        // never holds up the answer.
        Colors.themeFile.value("onSet", []).forEach(program => Quickshell.execDetached([program, name]));
        return "ok";
    }
}
