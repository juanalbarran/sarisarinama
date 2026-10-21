// quickshell/notifications/Toast.qml
// One notification on screen: its icon, the app, the summary, the body and
// the sender's buttons. A left click runs the sender's default action (or
// just closes it), a middle click closes it, and so does the ✕. It counts
// down while shown and not under the pointer; a critical one never does.
import QtQuick
import "../theme/"

Rectangle {
    id: root

    // The model row's roles, see NotifModel.snapshot.
    required property string key
    required property string app
    required property string summary
    required property string body
    required property int urgency
    required property string image
    required property string icon
    required property string actions
    required property bool hasDefault
    required property int duration
    required property int revision

    // Whether the stack shows it; one waiting past toast.max does not count down.
    property bool shown: true

    readonly property bool critical: root.urgency === 2
    readonly property var buttons: {
        try {
            return JSON.parse(root.actions);
        } catch (e) {
            return [];
        }
    }

    implicitWidth: Style.notifications.toast.width
    implicitHeight: content.implicitHeight + 2 * Style.notifications.toast.padding
    radius: Style.notifications.toast.radius
    color: Colors.notifications.background
    border.width: Style.notifications.toast.border
    border.color: root.critical ? Colors.notifications.urgent : Colors.notifications.border

    HoverHandler {
        id: hover
    }

    Timer {
        id: countdown
        interval: root.duration
        running: root.duration > 0 && root.shown && !hover.hovered
        onTriggered: NotificationCenter.expire(root.key)
    }

    // An update (replaces_id) starts the countdown over.
    onRevisionChanged: if (countdown.running)
        countdown.restart()

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton || !root.hasDefault)
                NotificationCenter.dismiss(root.key);
            else
                NotificationCenter.activate(root.key);
        }
    }

    Row {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Style.notifications.toast.padding
        spacing: Style.notifications.toast.padding

        NoticeIcon {
            id: noticeIcon
            row: ({
                    app: root.app,
                    summary: root.summary,
                    image: root.image,
                    icon: root.icon
                })
            size: Style.notifications.toast.iconSize
            radius: Style.notifications.toast.radius
            tile: root.critical ? Colors.notifications.urgent : Colors.notifications.accent
            letterColor: Colors.notifications.background
            fontFamily: Style.notifications.font.family
        }

        Column {
            width: parent.width - noticeIcon.width - parent.spacing
            spacing: Style.space(3)

            Item {
                width: parent.width
                implicitHeight: Math.max(appName.implicitHeight, close.implicitHeight)

                Text {
                    id: appName
                    anchors.left: parent.left
                    anchors.right: close.left
                    anchors.rightMargin: Style.space(6)
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.app.toUpperCase()
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    color: Colors.notifications.muted
                    font.family: Style.notifications.font.family
                    font.pixelSize: Style.notifications.font.caption
                    font.bold: true
                    font.letterSpacing: 1.2
                }

                Text {
                    id: close
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰅖"
                    color: closeMouse.containsMouse ? Colors.notifications.text : Colors.notifications.muted
                    font.family: Style.notifications.font.family
                    font.pixelSize: Style.notifications.font.body

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        anchors.margins: -Style.space(4)
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationCenter.dismiss(root.key)
                    }
                }
            }

            Text {
                width: parent.width
                visible: root.summary !== ""
                text: root.summary
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                color: root.critical ? Colors.notifications.urgent : Colors.notifications.text
                font.family: Style.notifications.font.family
                font.pixelSize: Style.notifications.font.title
                font.bold: true
            }

            Text {
                width: parent.width
                visible: root.body !== ""
                text: root.body
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                maximumLineCount: Style.notifications.toast.bodyLines
                elide: Text.ElideRight
                color: Colors.notifications.text
                font.family: Style.notifications.font.family
                font.pixelSize: Style.notifications.font.body
            }

            Flow {
                width: parent.width
                visible: root.buttons.length > 0
                topPadding: Style.space(4)
                spacing: Style.notifications.pill.gap
                layoutDirection: Qt.RightToLeft

                Repeater {
                    model: root.buttons

                    Rectangle {
                        id: button

                        required property var modelData

                        implicitWidth: label.implicitWidth + 2 * Style.notifications.pill.paddingX
                        implicitHeight: label.implicitHeight + 2 * Style.notifications.pill.paddingY
                        radius: Style.notifications.pill.radius
                        color: buttonMouse.containsMouse ? Colors.notifications.current : "transparent"
                        border.width: Style.notifications.card.border
                        border.color: buttonMouse.containsMouse ? Colors.notifications.accent : Colors.notifications.separator

                        Text {
                            id: label
                            anchors.centerIn: parent
                            text: button.modelData.text
                            textFormat: Text.PlainText
                            color: Colors.notifications.text
                            font.family: Style.notifications.font.family
                            font.pixelSize: Style.notifications.font.caption
                            font.bold: true
                        }

                        MouseArea {
                            id: buttonMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotificationCenter.invoke(root.key, button.modelData.id)
                        }
                    }
                }
            }
        }
    }
}
