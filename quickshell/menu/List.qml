// quickshell/menu/List.qml
// Keyboard-driven list over Model.rows. Vim keys and arrows navigate,
// Enter/l activate, h/Backspace go back, Escape asks the window to close.
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
        color: Colors.base01
        radius: 4
    }

    Connections {
        target: root.menu
        function onNavigated() {
            root.currentIndex = 0;
        }
    }

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_J:
        case Qt.Key_Down:
            root.incrementCurrentIndex();
            break;
        case Qt.Key_K:
        case Qt.Key_Up:
            root.decrementCurrentIndex();
            break;
        case Qt.Key_H:
        case Qt.Key_Backspace:
            root.menu.goBack();
            break;
        case Qt.Key_L:
        case Qt.Key_Return:
        case Qt.Key_Enter:
            root.activated(root.currentIndex);
            break;
        default:
            return;
        }
        event.accepted = true;
    }
    Keys.onEscapePressed: root.closeRequested()
}
