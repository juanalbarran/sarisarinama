# modules/ui/theme/integrations/qutebrowser/_lib/darkmode.py
# sarisarinama: dark pages with a dark theme, light pages with a light one,
# the setting the ,d key cycles. palette.json is read now, for the first
# window, and watched, so a theme set reaches an open qutebrowser too. The
# setting changes only when the theme's mode does, so a page toggled by
# hand stays as it is until the next switch between dark and light.
def _sarisarinama_darkmode(state):
    import json
    import os

    from qutebrowser.qt.core import (
        QCoreApplication,
        QFileSystemWatcher,
        QObject,
        Qt,
        pyqtSignal,
        pyqtSlot,
    )

    path = os.path.join(state, "palette.json")
    last = {"mode": None}

    def apply():
        try:
            with open(path) as f:
                mode = json.load(f).get("mode")
        except (OSError, ValueError):
            return
        if mode != last["mode"]:
            last["mode"] = mode
            config.set("colors.webpage.darkmode.enabled", mode != "light")

    apply()

    # config.py runs before qutebrowser creates its application, and a
    # watcher needs the event loop. A queued signal is held until the loop
    # runs, so the watcher is made then, owned by the application.
    def watch():
        app = QCoreApplication.instance()
        # :config-source runs this file again; one watcher is enough.
        if app.findChild(QFileSystemWatcher, "sarisarinama-palette"):
            return
        os.makedirs(state, exist_ok=True)
        watcher = QFileSystemWatcher([state], app)
        watcher.setObjectName("sarisarinama-palette")
        # palette.json is renamed over, never written in place: the
        # directory changes, the old file is gone.
        watcher.directoryChanged.connect(lambda _: apply())

    # The slot is a method of the sender: a plain function as a queued slot
    # crashed qutebrowser 3.7 when the call was delivered.
    class Later(QObject):
        fire = pyqtSignal()

        @pyqtSlot()
        def run(self):
            watch()

    later = Later()
    later.fire.connect(later.run, Qt.ConnectionType.QueuedConnection)
    later.fire.emit()
    # Kept past the end of this file, until the loop delivers the call.
    _sarisarinama_darkmode.keep = (later, watch, apply)


_sarisarinama_darkmode("@state@")
