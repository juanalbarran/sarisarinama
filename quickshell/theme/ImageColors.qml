// quickshell/theme/ImageColors.qml
// The `image` block of surfaces.json: every panel's tokens, from
// PanelColors, for the caption card, plus the wash over the desktop.
import QtQuick

PanelColors {
    id: root

    readonly property color backdrop: root.paint("backdrop", "background", "#0d0d0d", 0.92)
}
