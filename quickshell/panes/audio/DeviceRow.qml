// quickshell/panes/audio/DeviceRow.qml
// One output or input device: its icon and its name, washed when it is
// the default. Enter, or a click, makes it the default. The row holds an
// id and a name, never the node; it looks the node up while it lives.
import QtQuick
import "../../theme/"
import "audiomodel.js" as AudioModel

Rectangle {
    id: root

    required property var row
    // "out" or "in": which section the row belongs to.
    required property string kind
    required property AudioState audio
    required property Cursor cursor

    readonly property var node: audio.nodeFor(row)
    readonly property string lineId: kind + ":" + row.id
    readonly property bool selected: cursor.at(lineId, 0)
    readonly property bool current: node !== null && node === (kind === "out" ? audio.sink : audio.source)

    implicitHeight: Math.max(icon.implicitHeight, label.implicitHeight) + 2 * Style.audio.row.paddingY
    radius: Style.audio.row.radius
    color: root.selected ? Colors.audio.hover : (root.current ? Colors.audio.current : "transparent")

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.cursor.select(root.lineId, 0)
        onClicked: root.audio.setDefault(root.node)
    }

    Text {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: Style.audio.row.paddingX
        anchors.verticalCenter: parent.verticalCenter
        text: root.kind === "out" ? AudioModel.outputGlyph(root.node) : AudioModel.inputGlyph(root.node)
        color: root.current ? Colors.audio.accent : Colors.audio.muted
        font.family: Style.audio.font.family
        font.pixelSize: Style.audio.font.title
    }

    Text {
        id: label
        anchors.left: icon.right
        anchors.leftMargin: Style.audio.row.gap
        anchors.right: parent.right
        anchors.rightMargin: Style.audio.row.paddingX
        anchors.verticalCenter: parent.verticalCenter
        text: AudioModel.deviceLabel(root.node)
        elide: Text.ElideRight
        color: root.current ? Colors.audio.text : Colors.audio.muted
        font.family: Style.audio.font.family
        font.pixelSize: Style.audio.font.body
    }
}
