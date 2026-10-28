// quickshell/panes/image/ImageState.qml
// Which image the viewer shows and the folder it sits in, read through a
// FolderListModel so h and l step over the images beside it in name order.
// The viewport and the caption only draw it.
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import "imagemodel.js" as ImageModel

QtObject {
    id: root

    // The file in view, a plain absolute path; "" shows nothing.
    property string path: ""

    readonly property string name: ImageModel.basename(root.path)
    readonly property string dir: root.path !== "" ? ImageModel.dirname(root.path) : ""
    readonly property bool animated: ImageModel.isAnimated(root.path)

    readonly property FolderListModel folder: FolderListModel {
        folder: ImageModel.toUrl(root.dir)
        nameFilters: ImageModel.nameFilters()
        showDirs: false
        showHidden: true
        sortField: FolderListModel.Name
        caseSensitive: false
    }

    // The model lists the folder asynchronously: until it is Ready the
    // position is unknown, and an image opened outside the filter (an
    // extension it lacks) has no position at all.
    readonly property int count: folder.status === FolderListModel.Ready ? folder.count : 0
    readonly property int index: {
        if (root.count === 0)
            return -1;
        for (var i = 0; i < root.count; i++) {
            if (folder.get(i, "filePath") === root.path)
                return i;
        }
        return -1;
    }

    function show(arg) {
        root.path = ImageModel.toPath(arg, Quickshell.env("HOME"));
    }

    // The next (by = 1) or previous (by = -1) image in the folder.
    function move(by) {
        var i = ImageModel.step(root.index, root.count, by);
        if (i >= 0)
            root.path = folder.get(i, "filePath");
    }

    function first() {
        if (root.count > 0)
            root.path = folder.get(0, "filePath");
    }

    function last() {
        if (root.count > 0)
            root.path = folder.get(root.count - 1, "filePath");
    }
}
