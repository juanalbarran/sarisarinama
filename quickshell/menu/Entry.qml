// quickshell/menu/Entry.qml
// One row of the menu list: icon, label and a chevron for submenus. Reports
// hover and clicks to the ListView it belongs to.
import QtQuick
import "../theme/"

Text {
    id: root

    required property var modelData
    required property int index

    width: ListView.view ? ListView.view.width : implicitWidth
    padding: 6
    text: (modelData.icon ? modelData.icon + "  " : "") + modelData.label + (modelData.menu ? "  " : "")
    color: ListView.isCurrentItem ? Colors.accent : Colors.text
    font.family: "JetBrains Mono Nerd Font"
    font.pixelSize: 12

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.ListView.view.currentIndex = root.index
        onClicked: root.ListView.view.activated(root.index)
    }
}
