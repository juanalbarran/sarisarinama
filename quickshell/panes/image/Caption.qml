// quickshell/panes/image/Caption.qml
// The card under the image: the file's name, where it sits in its folder,
// its size and the zoom, and the viewer's keys on a line of their own.
import QtQuick
import "../../theme/"

Rectangle {
    id: root

    required property ImageState images
    required property Viewport viewport

    // Hidden with i, for a clean look at the image.
    property bool hints: true

    implicitWidth: content.implicitWidth + 2 * Style.image.card.padding
    implicitHeight: content.implicitHeight + 2 * Style.image.card.padding

    color: Colors.image.background
    radius: Style.image.card.radius
    border.width: Style.image.card.border
    border.color: Colors.image.border

    function facts() {
        var out = [];
        if (images.index >= 0)
            out.push((images.index + 1) + " / " + images.count);
        if (viewport.ready)
            out.push(viewport.sourceWidth + "×" + viewport.sourceHeight);
        if (viewport.ready)
            out.push(Math.round(viewport.actual * 100) + "%");
        if (viewport.failed)
            out.push("CANNOT READ THIS FILE");
        return out.join("  ·  ");
    }

    Column {
        id: content
        anchors.centerIn: parent
        spacing: Style.space(4)

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            // Long names stop at the screen's width less the margins.
            width: Math.min(implicitWidth, Style.image.caption.maxWidth)
            text: root.images.name !== "" ? root.images.name : "No image"
            elide: Text.ElideMiddle
            color: Colors.image.text
            font.family: Style.image.font.family
            font.pixelSize: Style.image.font.body
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.facts()
            visible: text !== ""
            color: root.viewport.failed ? Colors.image.urgent : Colors.image.muted
            font.family: Style.image.font.family
            font.pixelSize: Style.image.font.caption
            font.bold: true
            font.letterSpacing: 1.2
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.hints
            text: "h l  previous / next    + -  zoom    0  fit    1  actual size    H J K L  pan    i  hints    q  close"
            color: Colors.image.muted
            font.family: Style.image.font.family
            font.pixelSize: Style.image.font.caption
        }
    }
}
