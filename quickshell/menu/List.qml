// quickshell/menu/List.qml
// Keyboard-driven list over Model.rows: Ctrl+N/Ctrl+P move, Enter
// activates, Escape asks the window to close; Back is a row like any other.
// Shows at most maxRows rows and scrolls to keep the current one in view.
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

    // Keep the current row in view, scrolling only as far as needed. Done
    // here rather than left to the highlight, whose follow is animated.
    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

    highlight: Rectangle {
        color: Colors.menu.selectedBackground
        radius: 4
    }

    // A new menu, or a new filter, starts at the first row.
    Connections {
        target: root.menu
        function onNavigated() {
            root.currentIndex = 0;
        }
        function onQueryChanged() {
            root.currentIndex = 0;
        }
    }

    // The four keys the menu answers to. Search.qml calls this too, so they
    // work while the filter box holds the keyboard; any other key is left
    // unaccepted, for the box to type.
    function handleKey(event) {
        const ctrl = (event.modifiers & Qt.ControlModifier) !== 0;
        const key = event.key;
        if (ctrl && key === Qt.Key_N)
            root.incrementCurrentIndex();
        else if (ctrl && key === Qt.Key_P)
            root.decrementCurrentIndex();
        else if (key === Qt.Key_Return || key === Qt.Key_Enter)
            root.activated(root.currentIndex);
        else if (key === Qt.Key_Escape)
            root.closeRequested();
        else
            return;
        event.accepted = true;
    }

    Keys.onPressed: event => root.handleKey(event)
}
