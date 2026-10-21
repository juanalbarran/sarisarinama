// quickshell/notifications/NoticeIcon.qml
// A notification's icon, the first that loads of: the sender's picture, the
// app's icon from the icon theme, the app's first letter on a tile. Shared
// by the toasts and the history panel.
import QtQuick
import Quickshell
import "notifmodel.js" as NotifModel

Item {
    id: root

    // A NotifModel.snapshot row.
    property var row: ({})
    property int size: 40
    property int radius: 8
    property color tile: "#bad7ff"
    property color letterColor: "#0d0d0d"
    property string fontFamily: ""

    readonly property string themed: root.row.icon ? Quickshell.iconPath(root.row.icon, true) : ""
    // A picture that fails to load (a file already gone) gives way to the icon.
    property bool pictureFailed: false
    readonly property string source: root.row.image && !root.pictureFailed ? root.row.image : root.themed

    onRowChanged: root.pictureFailed = false
    readonly property bool pictured: picture.status === Image.Ready

    implicitWidth: root.size
    implicitHeight: root.size

    Image {
        id: picture
        anchors.fill: parent
        source: root.source
        sourceSize.width: root.size * 2
        sourceSize.height: root.size * 2
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
        visible: root.pictured
        onStatusChanged: if (status === Image.Error && root.row.image && source == root.row.image)
            root.pictureFailed = true
    }

    Rectangle {
        anchors.fill: parent
        visible: !root.pictured
        radius: root.radius
        color: root.tile

        Text {
            anchors.centerIn: parent
            text: NotifModel.initial(root.row)
            color: root.letterColor
            font.family: root.fontFamily
            font.pixelSize: Math.round(root.size * 0.45)
            font.bold: true
        }
    }
}
