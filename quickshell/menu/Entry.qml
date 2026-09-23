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
    height: Style.menu.rowHeight
    leftPadding: Style.menu.row.paddingX
    rightPadding: Style.menu.row.paddingX
    verticalAlignment: Text.AlignVCenter
    text: (modelData.icon ? modelData.icon + "  " : "") + modelData.label + (modelData.menu ? "  " : "")
    color: ListView.isCurrentItem ? Colors.accent : Colors.text
    font.family: Style.font.family
    font.pixelSize: Style.font.body

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.ListView.view.currentIndex = root.index
        onClicked: root.ListView.view.activated(root.index)
    }
}
