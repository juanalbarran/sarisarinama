// quickshell/menu/Menu.qml
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../theme/"

PanelWindow {
    id: root
    visible: false

    implicitWidth: 500
    implicitHeight: 400
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onVisibleChanged: if (visible)
        list.currentIndex = 0

    IpcHandler {
        target: "menu"

        function toggle(): void {
            root.visible = !root.visible;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.background
        radius: 8
        border.color: Colors.accent

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Text {
                id: title
                text: "menu"
                color: Colors.accent
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 12
            }

            ListView {
                id: list
                width: parent.width
                height: parent.height - title.height - parent.spacing
                focus: true
                clip: true
                keyNavigationWraps: true

                model: ["  Lock", "󰐥  Power off", "  Restart", "  Projects"]

                delegate: Text {
                    required property string modelData
                    required property int index

                    width: list.width
                    text: modelData
                    padding: 6
                    color: ListView.isCurrentItem ? Colors.accent : Colors.text
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 12
                }

                highlight: Rectangle {
                    color: Colors.base01
                    radius: 4
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_J) {
                        list.incrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_K) {
                        list.decrementCurrentIndex();
                        event.accepted = true;
                    }
                }
                Keys.onEscapePressed: root.visible = false
                Keys.onReturnPressed: console.log("selected:", list.currentIndex, list.model[list.currentIndex])
            }
        }
    }
}
