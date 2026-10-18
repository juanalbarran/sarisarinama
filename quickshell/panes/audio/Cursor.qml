// quickshell/panes/audio/Cursor.qml
// The audio panel's cursor: a LineCursor whose lines are, top to bottom,
// the output slider and the outputs, the input slider and the inputs, and
// the apps. Enter on a device makes it the default; on a slider or an app
// it mutes. Every line has one stop, so h and l are free: on a slider or
// an app they nudge its volume, see slide().
import QtQuick
import "../common/"

LineCursor {
    id: root

    required property AudioState audio

    // As the bar's wheel.
    readonly property real step: 0.05

    lines: {
        var result = [];
        if (root.audio.sink)
            result.push({
                id: "out:vol",
                stops: 1
            });
        root.audio.outputRows.forEach(r => result.push({
                    id: "out:" + r.id,
                    stops: 1
                }));
        if (root.audio.source)
            result.push({
                id: "in:vol",
                stops: 1
            });
        root.audio.inputRows.forEach(r => result.push({
                    id: "in:" + r.id,
                    stops: 1
                }));
        root.audio.appRows.forEach(r => result.push({
                    id: "app:" + r.id,
                    stops: 1
                }));
        return result;
    }

    function isVolume(line) {
        return line === "out:vol" || line === "in:vol" || line.startsWith("app:");
    }

    // The node a line acts on: the default device for a slider, else the
    // device or app the line names.
    function nodeAt(line) {
        if (line === "out:vol")
            return root.audio.sink;
        if (line === "in:vol")
            return root.audio.source;
        return root.audio.nodeById(Number(line.slice(line.indexOf(":") + 1)));
    }

    // Takes h and l on a volume line before handleKey sees them. Returns
    // whether it did, so the panel passes every other key on.
    function slide(event) {
        if (root.blocked || (event.modifiers & Qt.ControlModifier) || !root.isVolume(root.lineId))
            return false;
        if (event.key !== Qt.Key_H && event.key !== Qt.Key_L)
            return false;
        root.audio.nudge(root.nodeAt(root.lineId), event.key === Qt.Key_L ? root.step : -root.step);
        event.accepted = true;
        return true;
    }

    onActivated: (line, stop) => {
        if (root.isVolume(line))
            root.audio.toggleMute(root.nodeAt(line));
        else
            root.audio.setDefault(root.nodeAt(line));
    }
}
