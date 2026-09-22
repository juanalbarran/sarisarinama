// quickshell/menu/Model.qml
// Navigation state for one menu session: the trail of files we came from and
// what each row does. Knows nothing about windows or widgets.
import QtQuick
import Quickshell

QtObject {
    id: root

    readonly property File file: File {}
    property var navStack: []
    readonly property bool canGoBack: navStack.length > 0

    // Entries plus a synthetic Back row when opened from another menu.
    readonly property var rows: canGoBack ? file.entries.concat([
        {
            icon: "󰁍",
            label: "Back",
            back: true
        }
    ]) : file.entries

    // Fired whenever a different file is shown, so the list can reset.
    signal navigated

    function show(path) {
        root.file.load(path);
        root.navigated();
    }

    function enter(path) {
        root.navStack = root.navStack.concat([root.file.path]);
        root.show(path);
    }

    function goBack() {
        if (!root.canGoBack)
            return;
        var previous = root.navStack[root.navStack.length - 1];
        root.navStack = root.navStack.slice(0, -1);
        root.show(previous);
    }

    // Returns true when an action ran and the menu should close.
    function activate(index) {
        var row = root.rows[index];
        if (!row)
            return false;
        if (row.back)
            root.goBack();
        else if (row.menu)
            root.enter(row.menu);
        else if (row.action)
            Quickshell.execDetached(["bash", "-lc", row.action]);
        return !!row.action;
    }
}
