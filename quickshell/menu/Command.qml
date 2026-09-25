// quickshell/menu/Command.qml
// A menu whose rows come from a command: every non-empty line of stdout
// becomes one entry. In `command` and `action`, `{shell}` is replaced by
// the running config path and `{}` by the line, so a row can call the
// shell back over IPC without knowing where it was launched from.
import Quickshell
import Quickshell.Io

Process {
    id: root

    property var spec: ({})
    property var entries: []

    function fill(template, line) {
        if (typeof template !== "string")
            return "";
        return template.split("{shell}").join(Quickshell.shellDir).split("{}").join(line);
    }

    function run(newSpec) {
        root.entries = [];
        root.spec = newSpec || {};
        if (!root.spec.command)
            return;
        root.command = ["bash", "-lc", root.fill(root.spec.command, "")];
        root.running = true;
    }

    stdout: StdioCollector {
        onStreamFinished: {
            var out = [];
            var lines = text.split("\n");
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (line !== "")
                    out.push({
                        icon: root.spec.icon || "",
                        label: line,
                        action: root.fill(root.spec.action, line)
                    });
            }
            root.entries = out;
        }
    }
}
