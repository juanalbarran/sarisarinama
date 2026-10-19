// quickshell/wallpaper/Wallpaper.qml
// The theme's wallpaper, on every screen, below every window. The image
// is the theme's default from wallpapers.json, so a `theme set` swaps it
// with the colours. A theme with no wallpaper shows its background colour.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme/"

Scope {
    id: root

    ConfigFile {
        id: config
        name: "wallpapers"
    }

    readonly property var current: config.data[Colors.themeName] || {}
    readonly property string path: root.current.default || ""

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "sarisarinama-wallpaper"
            color: Colors.lookup("background", "#0d0d0d")

            Image {
                anchors.fill: parent
                source: root.path !== "" ? "file://" + root.path : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                // Decoded at the screen's size, not the file's: omarchy's
                // are up to 8192 px wide.
                sourceSize.width: parent.width
                sourceSize.height: parent.height
            }
        }
    }
}
