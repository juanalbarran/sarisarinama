// quickshell/theme/KeybindsColors.qml
// The `keybinds` block of surfaces.json: every panel's tokens, from
// PanelColors, plus the keycaps and the group headings.
import QtQuick

PanelColors {
    id: root

    readonly property color keycap: root.paint("keycap", "lighter_background", "#1a1a1a", 1.0)
    readonly property color keycapEdge: root.paint("keycapEdge", "muted", "#373737", 1.0)
    readonly property color keycapText: root.paint("keycapText", "foreground", "#e1e1e1", 1.0)
    readonly property color match: root.paint("match", "accent", "#bad7ff", 1.0)
}
