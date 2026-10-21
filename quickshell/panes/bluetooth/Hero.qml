// quickshell/panes/bluetooth/Hero.qml
// The top row of the panel: the radio's glyph, whether it is on, scanning
// or how many devices are connected, and on the right the power switch.
import QtQuick
import "../../theme/"
import "../common/"
import "btmodel.js" as BtModel

Item {
    id: root

    required property BtState bt
    required property Cursor cursor

    implicitHeight: Math.max(icon.implicitHeight, labels.implicitHeight, toggle.implicitHeight)

    Text {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: BtModel.radioGlyph(root.bt.available, root.bt.on, root.bt.connectedCount > 0)
        color: root.bt.on ? Colors.bluetooth.accent : Colors.bluetooth.muted
        font.family: Style.bluetooth.font.family
        font.pixelSize: Style.bluetooth.hero.iconSize
    }

    Column {
        id: labels
        anchors.left: icon.right
        anchors.leftMargin: Style.bluetooth.hero.gap
        anchors.right: toggle.visible ? toggle.left : parent.right
        anchors.rightMargin: toggle.visible ? Style.bluetooth.hero.gap : 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(2)

        Text {
            width: parent.width
            text: "Bluetooth"
            elide: Text.ElideRight
            color: Colors.bluetooth.text
            font.family: Style.bluetooth.font.family
            font.pixelSize: Style.bluetooth.font.title
            font.bold: true
        }

        Text {
            width: parent.width
            text: {
                if (!root.bt.available)
                    return "NO ADAPTER";
                if (root.bt.hardBlocked)
                    return "BLOCKED BY A SWITCH";
                if (!root.bt.on)
                    return "OFF";
                if (root.bt.connectedCount > 0)
                    return root.bt.connectedCount + " CONNECTED";
                return root.bt.discovering ? "SCANNING" : "ON";
            }
            elide: Text.ElideRight
            color: Colors.bluetooth.muted
            font.family: Style.bluetooth.font.family
            font.pixelSize: Style.bluetooth.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }
    }

    Toggle {
        id: toggle
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: root.bt.available && !root.bt.hardBlocked
        panelStyle: Style.bluetooth
        panelColors: Colors.bluetooth
        checked: root.bt.on
        hasCursor: root.cursor.at("power", 0)
        opacity: root.bt.powerBusy ? 0.5 : 1.0
        onToggled: root.bt.togglePower()
        onHovered: root.cursor.select("power", 0)
    }
}
