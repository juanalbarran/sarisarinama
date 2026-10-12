// quickshell/theme/NetworkColors.qml
// The `network` block of surfaces.json: every panel's tokens, from
// PanelColors, plus the password field.
import QtQuick

PanelColors {
    id: root

    readonly property color field: root.paint("field", "lighter_background", "#1a1a1a", 1.0)
    readonly property color fieldBorder: root.paint("fieldBorder", "accent", "#bad7ff", 1.0)
}
