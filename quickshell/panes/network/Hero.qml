// quickshell/panes/network/Hero.qml
// The top row of the panel: the connection icon, its name and state, and
// the Wi-Fi switch on the right. Everything it shows is read from NetState.
import QtQuick
import "../../theme/"

Item {
    id: root

    required property NetState net
    required property Cursor cursor

    implicitHeight: Math.max(icon.implicitHeight, labels.implicitHeight, toggle.implicitHeight)

    Text {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.net.icon
        color: root.net.restricted ? Colors.network.urgent : Colors.network.text
        font.family: Style.network.font.family
        font.pixelSize: Style.network.hero.iconSize
    }

    Column {
        id: labels
        anchors.left: icon.right
        anchors.leftMargin: Style.network.hero.gap
        anchors.right: toggle.visible ? toggle.left : parent.right
        anchors.rightMargin: toggle.visible ? Style.network.hero.gap : 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(2)

        Text {
            width: parent.width
            text: root.net.title
            elide: Text.ElideRight
            color: Colors.network.text
            font.family: Style.network.font.family
            font.pixelSize: Style.network.font.title
            font.bold: true
        }

        Text {
            width: parent.width
            text: root.net.status
            elide: Text.ElideRight
            color: root.net.restricted ? Colors.network.urgent : Colors.network.muted
            font.family: Style.network.font.family
            font.pixelSize: Style.network.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }
    }

    Toggle {
        id: toggle
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: root.net.canToggleWifi
        checked: root.net.wifiEnabled
        hasCursor: root.cursor.at("toggle", 0)
        onToggled: root.net.toggleWifi()
        onHovered: root.cursor.select("toggle", 0)
    }
}
