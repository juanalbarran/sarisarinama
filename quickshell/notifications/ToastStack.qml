// quickshell/notifications/ToastStack.qml
// The toasts' window, in the top-right corner: newest on top, at most
// style.notifications.toast.max of them; the rest wait their turn without
// counting down. It never takes the keyboard and only the cards take the
// pointer, so the corner stays usable around them.
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme/"

PanelWindow {
    id: root

    visible: NotificationCenter.toasts.count > 0

    anchors {
        top: true
        right: true
    }
    margins {
        top: Style.notifications.toast.margin
        right: Style.notifications.toast.margin
    }
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Style.notifications.toast.width
    implicitHeight: Math.max(1, stack.implicitHeight)
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sarisarinama-notifications"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region {
        item: stack
    }

    Column {
        id: stack
        width: parent.width
        spacing: Style.notifications.toast.gap

        Repeater {
            model: NotificationCenter.toasts

            Toast {
                required property int index

                width: stack.width
                shown: index < Style.notifications.toast.max
                visible: shown
            }
        }
    }
}
