// quickshell/bar/BarFrame.qml
// The bar's body: its background, with the windows' corner radius from
// Compositor. On Sway the radius is zero, so it is a flat rectangle filling
// the window, the bar as it always was. No border. See docs/bar.md.
import QtQuick
import "../theme/"
import "../compositor/"

Rectangle {
    radius: Compositor.rounding
    // Hyprland's floating bar has a token of its own, so it can be
    // translucent while Sway's flush one stays as it was.
    color: Compositor.name === "hyprland" ? Colors.bar.hyprlandBackground : Colors.bar.background
}
