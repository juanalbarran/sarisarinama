// quickshell/lock/LockView.qml
// What one screen shows while locked: the time, the date and the password
// field. It only draws and reports; LockScreen decides. Enter submits,
// Escape or Ctrl+U clears what is typed.
import QtQuick
import Quickshell
import "../theme/"

Rectangle {
    id: root

    property bool checking: false
    property string failure: ""

    signal submitted(string password)
    signal edited

    color: Colors.lock.background

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // A click anywhere gives the field back its focus.
    MouseArea {
        anchors.fill: parent
        onClicked: input.forceActiveFocus()
    }

    Column {
        anchors.centerIn: parent
        spacing: Style.lock.gap

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(clock.date, "HH:mm")
            color: Colors.lock.text
            font.family: Style.lock.font.family
            font.pixelSize: Style.lock.clockSize
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(clock.date, "dddd, d MMMM")
            color: Colors.lock.muted
            font.family: Style.lock.font.family
            font.pixelSize: Style.lock.font.title
        }

        Rectangle {
            id: field
            anchors.horizontalCenter: parent.horizontalCenter
            width: Style.lock.field.width
            height: Style.lock.field.height
            radius: Style.lock.field.radius
            color: Colors.lock.field
            border.width: Style.lock.field.border
            border.color: root.failure !== "" ? Colors.lock.urgent : Colors.lock.fieldBorder

            TextInput {
                id: input
                anchors.fill: parent
                anchors.leftMargin: Style.lock.field.paddingX
                anchors.rightMargin: Style.lock.field.paddingX
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                clip: true
                focus: true
                echoMode: TextInput.Password
                passwordCharacter: "●"
                passwordMaskDelay: 0
                readOnly: root.checking
                color: Colors.lock.text
                font.family: Style.lock.font.family
                font.pixelSize: Style.lock.font.title

                onTextChanged: if (text !== "")
                    root.edited()

                onAccepted: {
                    var password = text;
                    text = "";
                    root.submitted(password);
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape || (event.key === Qt.Key_U && (event.modifiers & Qt.ControlModifier))) {
                        text = "";
                        event.accepted = true;
                    }
                }

                Component.onCompleted: forceActiveFocus()
            }

            // The hint, the check in progress or the failure, in the
            // empty field.
            Text {
                anchors.centerIn: parent
                visible: input.text === ""
                text: root.checking ? "Checking…" : (root.failure !== "" ? root.failure : "Password")
                color: root.failure !== "" && !root.checking ? Colors.lock.urgent : Colors.lock.muted
                font.family: Style.lock.font.family
                font.pixelSize: Style.lock.font.body
            }
        }
    }
}
