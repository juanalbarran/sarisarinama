// quickshell/panes/image/Viewport.qml
// The image itself: fitted to the viewport, zoomed about its centre and
// panned by a drag or by the keys. A GIF plays; anything else is drawn
// once. Zoom 1 is the fit, not the file's own size.
import QtQuick
import "../../theme/"
import "imagemodel.js" as ImageModel

Item {
    id: root

    required property ImageState images

    property real zoom: 1
    property real panX: 0
    property real panY: 0

    readonly property var picture: loader.item
    readonly property bool ready: picture !== null && picture.status === Image.Ready
    readonly property bool failed: picture !== null && picture.status === Image.Error
    readonly property int sourceWidth: ready ? picture.implicitWidth : 0
    readonly property int sourceHeight: ready ? picture.implicitHeight : 0

    readonly property real fit: ImageModel.fitScale(sourceWidth, sourceHeight, width, height)
    readonly property real shownWidth: sourceWidth * fit * zoom
    readonly property real shownHeight: sourceHeight * fit * zoom
    // What the caption calls 100%: the file's pixels, not the fit.
    readonly property real actual: fit * zoom

    function reset() {
        zoom = 1;
        panX = 0;
        panY = 0;
    }

    function zoomBy(factor) {
        zoom = ImageModel.clampZoom(zoom * factor, Style.image.zoom.max);
        pan(0, 0);
    }

    // Zoom so a file pixel is a screen pixel, or back to the fit.
    function actualSize() {
        if (!ready)
            return;
        zoom = Math.abs(actual - 1) < 0.001 ? 1 : ImageModel.clampZoom(1 / fit, Style.image.zoom.max);
        pan(0, 0);
    }

    function pan(dx, dy) {
        panX = ImageModel.clampPan(panX + dx, shownWidth, width);
        panY = ImageModel.clampPan(panY + dy, shownHeight, height);
    }

    onWidthChanged: pan(0, 0)
    onHeightChanged: pan(0, 0)

    Connections {
        target: root.images
        function onPathChanged() {
            root.reset();
        }
    }

    Loader {
        id: loader
        x: (root.width - root.shownWidth) / 2 + root.panX
        y: (root.height - root.shownHeight) / 2 + root.panY
        width: root.shownWidth
        height: root.shownHeight
        sourceComponent: root.images.animated ? animatedPicture : stillPicture
    }

    Component {
        id: stillPicture

        Image {
            source: ImageModel.toUrl(root.images.path)
            asynchronous: true
            autoTransform: true
            smooth: true
            mipmap: true
            fillMode: Image.Stretch
        }
    }

    Component {
        id: animatedPicture

        AnimatedImage {
            source: ImageModel.toUrl(root.images.path)
            asynchronous: true
            smooth: true
            fillMode: Image.Stretch
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        property real lastX: 0
        property real lastY: 0
        cursorShape: root.shownWidth > root.width || root.shownHeight > root.height ? Qt.OpenHandCursor : Qt.ArrowCursor
        onPressed: mouse => {
            lastX = mouse.x;
            lastY = mouse.y;
        }
        onPositionChanged: mouse => {
            root.pan(mouse.x - lastX, mouse.y - lastY);
            lastX = mouse.x;
            lastY = mouse.y;
        }
        onWheel: wheel => root.zoomBy(wheel.angleDelta.y > 0 ? Style.image.zoom.step : 1 / Style.image.zoom.step)
    }
}
