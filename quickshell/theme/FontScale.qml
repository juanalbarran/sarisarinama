// quickshell/theme/FontScale.qml
// One type scale: a family, a base size and the four steps derived from it.
// Style keeps one for the shell and one per component, so a component can
// override the family or the size and keep the ratios. See docs/style.md.
import QtQuick

QtObject {
    id: root

    property string family: "JetBrains Mono Nerd Font"
    property int size: 12

    readonly property int caption: Math.round(root.size * 0.833)
    readonly property int body: root.size
    readonly property int title: Math.round(root.size * 1.167)
    readonly property int heading: Math.round(root.size * 1.333)
}
