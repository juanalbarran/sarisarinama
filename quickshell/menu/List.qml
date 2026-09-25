// quickshell/menu/List.qml
// Keyboard-driven list over Model.rows. Ctrl+N/Ctrl+P and the arrows
// navigate, Enter/l activate, h/Backspace go back, Escape asks the window
// to close.
import QtQuick
import "../theme/"

ListView {
    id: root

    required property Model menu

    signal activated(int index)
    signal closeRequested

    model: menu.rows
    focus: true
    clip: true
    keyNavigationWraps: true

    delegate: Entry {}

    highlight: Rectangle {
        color: Colors.menu.selectedBackground
        radius: 4
    }

    Connections {
        target: root.menu
        function onNavigated() {
            root.currentIndex = 0;
        }
    }

    // Ctrl+N/Ctrl+P instead of j/k; a switch cannot express a modifier,
    // so the chords are spelled out.
    Keys.onPressed: event => {
        const ctrl = (event.modifiers & Qt.ControlModifier) !== 0;
        const key = event.key;
        if (key === Qt.Key_Down || (ctrl && key === Qt.Key_N))
            root.incrementCurrentIndex();
        else if (key === Qt.Key_Up || (ctrl && key === Qt.Key_P))
            root.decrementCurrentIndex();
        else if (key === Qt.Key_H || key === Qt.Key_Backspace)
            root.menu.goBack();
        else if (key === Qt.Key_L || key === Qt.Key_Return || key === Qt.Key_Enter)
            root.activated(root.currentIndex);
        else
            return;
        event.accepted = true;
    }
    Keys.onEscapePressed: root.closeRequested()
}
