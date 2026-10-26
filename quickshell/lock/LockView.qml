// quickshell/lock/LockView.qml
// What one screen shows while locked: the theme's wallpaper, blurred and
// dimmed, then the time, the date and the password field. It only draws
// and reports; LockScreen decides. Enter submits, Escape or Ctrl+U clears
// what is typed.
import QtQuick
import QtQuick.Effects
import Quickshell
import "../theme/"

Rectangle {
    id: root

    property bool checking: false
    property string failure: ""

    signal submitted(string password)
    signal edited

    color: Colors.lock.background

    // The wallpaper the desktop shows. Only the blur is drawn, so the image
    // itself stays hidden.
    Image {
        id: wallpaper
        anchors.fill: parent
        visible: false
        source: Wallpapers.current !== "" ? "file://" + Wallpapers.current : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: width
        sourceSize.height: height
    }

    MultiEffect {
        anchors.fill: wallpaper
        source: wallpaper
        visible: wallpaper.status === Image.Ready
        autoPaddingEnabled: false
        blurEnabled: Style.lock.blur > 0
        blur: 1.0
        blurMax: Style.lock.blur
    }

    // Keeps the time and the field readable on any image.
    Rectangle {
        anchors.fill: parent
        visible: wallpaper.status === Image.Ready
        color: Colors.lock.dim
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
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
                // No caret: the dots alone show what is typed.
                cursorDelegate: Item {}
                readOnly: root.checking
                color: Colors.lock.text
                font.family: Style.lock.font.family
                font.pixelSize: Style.lock.font.title
                font.letterSpacing: Style.lock.field.dotSpacing

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

    // Over everything, so no pointer shows anywhere, the field included,
    // and a click anywhere gives the field back its focus.
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.BlankCursor
        onClicked: input.forceActiveFocus()
    }
}
