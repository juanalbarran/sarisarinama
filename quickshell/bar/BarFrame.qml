// quickshell/bar/BarFrame.qml
// The bar's body: its background with the windows' corner radius and border,
// read from Compositor. On Sway they are all zero, so it is a flat rectangle
// filling the window, the bar as it always was. See docs/bar.md.
import QtQuick
import QtQuick.Shapes
import "../theme/"
import "../compositor/"

Item {
    id: root

    readonly property int borderSize: Compositor.border.size
    readonly property var colors: Compositor.border.colors
    // Hyprland rounds a window's content and draws the border outside it,
    // so the border's outer corner is the radius plus the border's width.
    readonly property int innerRadius: Compositor.rounding
    readonly property int outerRadius: innerRadius > 0 ? innerRadius + borderSize : 0

    Rectangle {
        anchors.fill: parent
        anchors.margins: root.borderSize
        radius: root.innerRadius
        // Hyprland's floating bar has a token of its own, so it can be
        // translucent while Sway's flush one stays as it was.
        color: Compositor.name === "hyprland" ? Colors.bar.hyprlandBackground : Colors.bar.background
    }

    // The ring between two rounded rectangles, filled with the gradient.
    // A Rectangle's border takes one color; Hyprland's can take several.
    // A gradient's stops are read once, so new colors (a theme set) build
    // the ring again; its stops are its children and go with it.
    Loader {
        id: ring
        anchors.fill: parent
        active: root.borderSize > 0 && root.colors.length > 0
        sourceComponent: ringComponent
    }

    onColorsChanged: {
        ring.sourceComponent = null;
        ring.sourceComponent = ringComponent;
    }

    Component {
        id: ringComponent

        Shape {
            id: shape
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: -1
                fillRule: ShapePath.OddEvenFill
                fillGradient: LinearGradient {
                    x1: root.line.x1
                    y1: root.line.y1
                    x2: root.line.x2
                    y2: root.line.y2
                    stops: root.colors.map((c, i, all) => stop.createObject(shape, {
                            position: all.length > 1 ? i / (all.length - 1) : 0,
                            color: c
                        }))
                }

                PathRectangle {
                    width: root.width
                    height: root.height
                    radius: root.outerRadius
                }
                PathRectangle {
                    x: root.borderSize
                    y: root.borderSize
                    width: root.width - 2 * root.borderSize
                    height: root.height - 2 * root.borderSize
                    radius: root.innerRadius
                }
            }
        }
    }

    Component {
        id: stop
        GradientStop {}
    }

    // Hyprland's border shader, not a CSS gradient. Over the box scaled to
    // 0..1, progress = x * (1 - sin a) + y * sin a, with x or y mirrored for
    // angles past 90°. That is a plane, so it is one straight gradient line:
    // start where progress is 0, end where it is 1.
    readonly property var line: {
        var a = ((Compositor.border.angle % 360) + 360) % 360 * Math.PI / 180;
        var flipX = false, flipY = false, f = a;
        if (a > 4.71) {
            flipY = true;
            f = 2 * Math.PI - a;
        } else if (a > 3.14) {
            flipX = true;
            flipY = true;
            f = a - Math.PI;
        } else if (a > 1.57) {
            flipX = true;
            f = Math.PI - a;
        }
        var s = Math.sin(f);
        var w = Math.max(1, root.width), h = Math.max(1, root.height);
        // progress = c + gx * X + gy * Y, in pixels
        var gx = (flipX ? -1 : 1) * (1 - s) / w;
        var gy = (flipY ? -1 : 1) * s / h;
        var c = (flipX ? 1 - s : 0) + (flipY ? s : 0);
        var n = gx * gx + gy * gy;
        return {
            x1: -c * gx / n,
            y1: -c * gy / n,
            x2: (1 - c) * gx / n,
            y2: (1 - c) * gy / n
        };
    }
}
