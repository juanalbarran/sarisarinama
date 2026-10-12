// quickshell/panes/monitor/MonState.qml
// The displays, as the compositor reports them, and the two changes the
// panel can make: a display on or off, and the scale of the focused one.
// They are read when the panel opens, after every change, and every few
// seconds while it is open, which is how a screen plugged in meanwhile
// shows up. The panel's one rule lives here: the last display that is on
// cannot be turned off.
import QtQuick
import "../../compositor/"
import "../../theme/"
import "monmodel.js" as MonModel

QtObject {
    id: root

    // True while the panel is open; only then are the outputs polled.
    property bool active: false

    readonly property var outputs: MonModel.sorted(Compositor.outputs)
    readonly property int activeCount: outputs.filter(o => o.active).length
    readonly property var target: MonModel.target(outputs)

    // The scales on offer, from ~/.config/sarisarinama/monitor.json.
    readonly property ConfigFile config: ConfigFile {
        name: "monitor"
    }
    readonly property var scales: root.config.value("scales", [1, 1.25, 1.5, 2]).map(MonModel.scaleId)
    readonly property string currentScale: target ? MonModel.scaleId(target.scale) : ""

    function canToggle(output) {
        return !output.active || root.activeCount > 1;
    }

    function toggle(name) {
        var output = root.outputs.find(o => o.name === name);
        if (output && root.canToggle(output))
            Compositor.setOutputEnabled(name, !output.active);
    }

    function setScale(id) {
        if (root.target && id !== root.currentScale)
            Compositor.setOutputScale(root.target.name, id);
    }

    function refresh() {
        Compositor.refreshOutputs();
    }

    onActiveChanged: {
        if (active)
            refresh();
    }

    property Timer poll: Timer {
        interval: 5000
        repeat: true
        running: root.active
        onTriggered: root.refresh()
    }
}
