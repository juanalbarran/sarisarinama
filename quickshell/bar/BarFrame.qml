// quickshell/bar/BarFrame.qml
// The bar's body: its background, with the windows' corner radius from
// Compositor. On Sway the radius is zero, so it is a flat rectangle filling
// the window, the bar as it always was. No border. See docs/bar.md.
import QtQuick
import "../theme/"
import "../compositor/"

Rectangle {
    radius: Compositor.rounding
    // Translucent under Hyprland by surfaces.json's hyprlandOpacity, which
    // Colors applies to every background.
    color: Colors.bar.background
}
