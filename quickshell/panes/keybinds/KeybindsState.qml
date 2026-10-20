// quickshell/panes/keybinds/KeybindsState.qml
// What the pane shows: the sections of cheatsheets.json, the one in view and
// the filter over it. The sections only draw it.
import QtQuick
import "../../theme/"
import "keymodel.js" as KeyModel

QtObject {
    id: root

    readonly property ConfigFile file: ConfigFile {
        name: "cheatsheets"
    }

    // [{id, label, icon, groups: [{title, binds: [{keys, description}]}]}],
    // in menu order.
    readonly property var sections: Array.isArray(file.data) ? file.data : []

    // Set by the payload; an unknown id shows the first section.
    property string sectionId: ""
    property string query: ""

    readonly property int index: Math.max(0, sections.findIndex(s => s.id === root.sectionId))
    readonly property var section: sections.length > 0 ? sections[index] : null
    readonly property var groups: section ? KeyModel.filterGroups(section.groups, query) : []
    readonly property int total: section ? KeyModel.count(section.groups) : 0
    readonly property int shown: KeyModel.count(groups)

    // Tab and Shift+Tab: the next or the previous section, wrapping round.
    function cycle(step) {
        var n = sections.length;
        if (n === 0)
            return;
        sectionId = sections[((index + step) % n + n) % n].id;
    }
}
