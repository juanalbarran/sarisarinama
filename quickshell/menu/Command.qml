// quickshell/menu/Command.qml
// A menu whose rows come from a command. Stdout that parses as a JSON array
// is the entry list verbatim, so one command can mix rows that act with rows
// that open a submenu; anything else is read as lines, one row each.
// In `command` and `action`, `{shell}` becomes the running config path,
// `{arg}` what the opening row carried, and `{}` the line.
import Quickshell
import Quickshell.Io

Process {
    id: root

    property var spec: ({})
    property string arg: ""
    property var entries: []

    // One shell word whatever the text holds: spaces stay, $(...) is not run
    function quote(text) {
        return "'" + text.split("'").join("'\\''") + "'";
    }

    function fill(template, line) {
        if (typeof template !== "string")
            return "";
        return template.split("{shell}").join(Quickshell.shellDir).split("{arg}").join(root.quote(root.arg)).split("{}").join(line);
    }

    function run(newSpec, newArg) {
        root.entries = [];
        root.spec = newSpec || {};
        root.arg = newArg || "";
        if (!root.spec.command)
            return;
        root.command = ["bash", "-lc", root.fill(root.spec.command, "")];
        root.running = true;
    }

    stdout: StdioCollector {
        onStreamFinished: {
            try {
                var parsed = JSON.parse(text);
                if (Array.isArray(parsed)) {
                    root.entries = parsed;
                    return;
                }
            } catch (e) {}
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
