// quickshell/bar/widgets/BluetoothStatus.qml
// Bluetooth: crossed out while off, with dots while a device is connected.
// Hidden without an adapter. A click asks for the panel, a right click
// turns Bluetooth on or off, as a right click on the speaker mutes. Not
// Bluetooth.qml: that is Quickshell.Bluetooth's own singleton.
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "../../theme/"
import "../../panes/bluetooth/btmodel.js" as BtModel

Text {
    id: root

    signal clicked

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: root.adapter !== null && root.adapter.enabled
    readonly property bool anyConnected: root.on && (Bluetooth.devices ? Bluetooth.devices.values : []).some(d => d && d.connected)

    visible: root.adapter !== null
    text: BtModel.radioGlyph(root.adapter !== null, root.on, root.anyConnected)
    color: mouse.containsMouse ? Colors.bar.hover : root.anyConnected ? Colors.bar.focused : Colors.bar.text
    font.family: Style.bar.font.family
    font.pixelSize: Style.bar.textSize("bluetooth", "body")

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: event => {
            if (event.button === Qt.RightButton)
                Quickshell.execDetached(["sarisarinama-bluetooth-power", root.on ? "off" : "on"]);
            else
                root.clicked();
        }
    }
}
