// quickshell/panes/battery/Hero.qml
// The top row of the panel: the battery icon, its status and, on the
// right, the charge in large type. Everything it shows is read from
// BatteryState.
import QtQuick
import "../../theme/"
import "batmodel.js" as BatModel

Item {
    id: root

    required property BatteryState battery

    implicitHeight: Math.max(icon.implicitHeight, labels.implicitHeight, percent.implicitHeight)

    Text {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.battery.icon
        color: root.battery.low ? Colors.battery.urgent : Colors.battery.accent
        font.family: Style.battery.font.family
        font.pixelSize: Style.battery.hero.iconSize
    }

    Column {
        id: labels
        anchors.left: icon.right
        anchors.leftMargin: Style.battery.hero.gap
        anchors.right: percent.left
        anchors.rightMargin: Style.battery.hero.gap
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(2)

        Text {
            width: parent.width
            text: "Battery"
            elide: Text.ElideRight
            color: Colors.battery.text
            font.family: Style.battery.font.family
            font.pixelSize: Style.battery.font.title
            font.bold: true
        }

        Text {
            width: parent.width
            text: root.battery.status.toUpperCase()
            elide: Text.ElideRight
            color: Colors.battery.muted
            font.family: Style.battery.font.family
            font.pixelSize: Style.battery.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }
    }

    Text {
        id: percent
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: BatModel.percent(root.battery.fraction)
        color: root.battery.low ? Colors.battery.urgent : Colors.battery.text
        font.family: Style.battery.font.family
        font.pixelSize: Style.battery.font.heading
        font.bold: true
    }
}
