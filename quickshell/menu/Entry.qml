// quickshell/menu/Entry.qml
// One row of the menu list: icon, label and a chevron for submenus. Reports
// hover and clicks to the ListView it belongs to.
import QtQuick
import Quickshell.Widgets
import "../theme/"

Text {
    id: root

    required property var modelData
    required property int index

    width: ListView.view ? ListView.view.width : implicitWidth
    height: Style.menu.rowHeight
    // An application row draws its icon in the padding, where the glyph was
    readonly property bool hasImage: !!modelData.image
    leftPadding: Style.menu.row.paddingX + (hasImage ? Style.menu.font.heading + Style.menu.font.body : 0)
    rightPadding: Style.menu.row.paddingX
    verticalAlignment: Text.AlignVCenter
    text: (modelData.icon && !hasImage ? modelData.icon + "  " : "") + modelData.label + (modelData.menu ? "  " : "")
    color: ListView.isCurrentItem ? Colors.menu.selectedText : Colors.menu.text
    font.family: Style.menu.font.family
    font.pixelSize: Style.menu.font.body

    IconImage {
        visible: root.hasImage
        source: root.modelData.image || ""
        implicitSize: Style.menu.font.heading
        asynchronous: true
        anchors.left: parent.left
        anchors.leftMargin: Style.menu.row.paddingX
        anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.ListView.view.currentIndex = root.index
        onClicked: root.ListView.view.activated(root.index)
    }
}
