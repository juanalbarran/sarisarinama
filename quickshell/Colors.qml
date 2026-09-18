// quickshell/Colors.qml

pragma Singleton
import Quickshell
import QtQuick

Singleton {
    // canaima base16 "dark" scheme
    readonly property color base00: "#131314"
    readonly property color base01: "#32302f"
    readonly property color base02: "#a9b1d6"
    readonly property color base03: "#665c54"
    readonly property color base05: "#ffffff"
    readonly property color base08: "#ea6962"
    readonly property color base0A: "#d8a657"
    readonly property color base0B: "#a9b665"
    readonly property color base0D: "#7aa2f7"

    // semantic aliases, mirroring templates/waybar.nix
    readonly property color background: base00
    readonly property color text: base02
    readonly property color accent: base0D
    readonly property color urgent: base08
    readonly property color hover: base0A
}
