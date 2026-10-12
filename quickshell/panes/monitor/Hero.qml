// quickshell/panes/monitor/Hero.qml
// The top row of the panel: a display icon, the title and how many
// displays are on. Everything it shows is read from MonState.
import QtQuick
import "../../theme/"
import "monmodel.js" as MonModel

Item {
    id: root

    required property MonState mon

    implicitHeight: Math.max(icon.implicitHeight, labels.implicitHeight)

    Text {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: MonModel.heroIcon(root.mon.activeCount)
        color: Colors.monitor.text
        font.family: Style.monitor.font.family
        font.pixelSize: Style.monitor.hero.iconSize
    }

    Column {
        id: labels
        anchors.left: icon.right
        anchors.leftMargin: Style.monitor.hero.gap
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(2)

        Text {
            width: parent.width
            text: "Displays"
            elide: Text.ElideRight
            color: Colors.monitor.text
            font.family: Style.monitor.font.family
            font.pixelSize: Style.monitor.font.title
            font.bold: true
        }

        Text {
            width: parent.width
            text: MonModel.status(root.mon.outputs, root.mon.activeCount)
            elide: Text.ElideRight
            color: Colors.monitor.muted
            font.family: Style.monitor.font.family
            font.pixelSize: Style.monitor.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }
    }
}
