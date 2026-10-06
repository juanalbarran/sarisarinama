// quickshell/menu/Model.qml
// Navigation state for one menu session: the trail of menus we came from,
// the filter, and what each row does. Knows nothing about windows or
// widgets. A trail entry is a file and an argument, because one command menu
// can serve many directories and Back must return to the right one.
import QtQuick
import Quickshell
import "../theme/"

QtObject {
    id: root
    readonly property File file: File {}
    property var navStack: []
    // A backWithin menu goes Back only to itself, so where it was first
    // opened, from another menu or over IPC, there is no Back row
    readonly property bool canGoBack: navStack.length > 0 && (!file.backWithin || navStack[navStack.length - 1].path === file.path)

    // A menu with more entries than filterAbove gets a filter. Back is not
    // an entry: it is never counted and never filtered out.
    readonly property bool filterable: file.entries.length > Style.menu.list.filterAbove
    property string query: ""
    readonly property var shown: {
        var q = root.query.toLowerCase();
        if (!root.filterable || q === "")
            return root.file.entries;
        return root.file.entries.filter(e => String(e.label).toLowerCase().indexOf(q) !== -1);
    }

    // The shown entries plus a synthetic Back row when opened from another menu.
    readonly property var rows: canGoBack ? shown.concat([
        {
            icon: "󰁍",
            label: "Back",
            back: true
        }
    ]) : shown

    // Fired whenever a different menu is shown, so the list can reset.
    signal navigated

    function show(path, arg) {
        root.query = "";
        root.file.load(path, arg);
        root.navigated();
    }

    function enter(path, arg) {
        root.navStack = root.navStack.concat([
            {
                path: root.file.path,
                arg: root.file.arg
            }
        ]);
        root.show(path, arg);
    }

    function goBack() {
        if (!root.canGoBack)
            return;
        var previous = root.navStack[root.navStack.length - 1];
        root.navStack = root.navStack.slice(0, -1);
        root.show(previous.path, previous.arg);
    }

    // Returns true when an action ran and the menu should close.
    function activate(index) {
        var row = root.rows[index];
        if (!row)
            return false;
        if (row.back)
            root.goBack();
        else if (row.menu)
            root.enter(row.menu, row.arg);
        else if (row.action)
            Quickshell.execDetached(["bash", "-lc", row.action]);
        return !!row.action;
    }
}
