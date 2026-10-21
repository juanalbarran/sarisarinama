// quickshell/panes/keybinds/KeybindsState.qml
// What the pane shows: the sections of cheatsheets.json and the one in view.
// The sections only draw it.
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

    readonly property int index: Math.max(0, sections.findIndex(s => s.id === root.sectionId))
    readonly property var section: sections.length > 0 ? sections[index] : null
    readonly property var groups: section && Array.isArray(section.groups) ? section.groups : []
    readonly property int total: KeyModel.count(groups)

    // Tab and Shift+Tab: the next or the previous section, wrapping round.
    function cycle(step) {
        var n = sections.length;
        if (n === 0)
            return;
        sectionId = sections[((index + step) % n + n) % n].id;
    }
}
