// quickshell/panes/network/Passphrase.qml
// The password prompt that opens under a row. Enter or the check mark
// connects, Escape cancels. What is typed is kept in NetState, so a list
// refresh that rebuilds the row does not lose it. The password reaches
// NetworkManager over D-Bus, never on a command line.
import QtQuick
import "../../theme/"

Rectangle {
    id: root

    required property NetState net
    required property string ssid

    implicitHeight: input.implicitHeight + 2 * Style.network.field.paddingY
    radius: Style.network.field.radius
    color: Colors.network.field
    border.width: Style.network.field.border
    border.color: Colors.network.fieldBorder

    TextInput {
        id: input
        anchors.left: parent.left
        anchors.right: submit.left
        anchors.leftMargin: Style.network.field.paddingX
        anchors.rightMargin: Style.network.field.paddingX
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        echoMode: TextInput.Password
        enabled: !root.net.busy
        color: Colors.network.text
        font.family: Style.network.font.family
        font.pixelSize: Style.network.font.body

        // Typing replaces a `text:` binding, so the text is copied in once
        // and copied out on every change instead.
        Component.onCompleted: {
            text = root.net.passwordText;
            forceActiveFocus();
        }
        onTextChanged: root.net.passwordText = text
        onAccepted: root.net.connectWithPassword(root.ssid)
        Keys.onEscapePressed: root.net.cancelPassword()

        Text {
            visible: input.text === ""
            text: "Password"
            color: Colors.network.muted
            font: input.font
        }
    }

    Text {
        id: submit
        anchors.right: parent.right
        anchors.rightMargin: Style.network.field.paddingX
        anchors.verticalCenter: parent.verticalCenter
        text: "󰄬"
        color: input.text !== "" ? Colors.network.accent : Colors.network.muted
        font.family: Style.network.font.family
        font.pixelSize: Style.network.font.title

        MouseArea {
            anchors.fill: parent
            enabled: input.text !== "" && !root.net.busy
            cursorShape: Qt.PointingHandCursor
            onClicked: root.net.connectWithPassword(root.ssid)
        }
    }
}
