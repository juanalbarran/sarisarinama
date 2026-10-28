# Bluetooth panel

The radio and its devices: a power switch, the devices connected, the ones
paired, and what a scan finds while the panel is open. A click (or Enter)
connects a paired device, disconnects a connected one, and pairs a new
one. After omarchy quattro's `shell/plugins/panels/bluetooth`.

```
qs -p $SARISARINAMA_PATH ipc call shell toggle bluetooth '{}'
```

A click on the bar's Bluetooth icon, or the Services menu's **Bluetooth** row,
summons it. A right click on the icon turns Bluetooth on or off, as a
right click on the speaker mutes. The icon is hidden without an adapter.

## Where the state comes from

`Quickshell.Bluetooth` (0.3.0) reads BlueZ over D-Bus:
`Bluetooth.defaultAdapter` for the switch and the scan, `Bluetooth.devices`
for the list. Quickshell follows BlueZ, so nothing is polled. Each device
becomes a plain row (`btmodel.js` `snapshot`), never the device itself:
BlueZ drops a device when a scan times out or it is forgotten, and a
delegate still holding it crashes the shell, as omarchy found. Devices
announcing only an address or a UUID are left out.

| Section   | Shows                                             |
| --------- | ------------------------------------------------- |
| CONNECTED | connected devices, with the battery when reported |
| PAIRED    | paired, bonded or trusted, not connected          |
| AVAILABLE | the rest, only while scanning                     |

The adapter scans only while the panel is open: a scan costs power and
slows connections. BlueZ can end a scan by itself, and Quickshell only
forwards a write that differs from the last one, so the panel asks again
every second until the scan runs, and on closing stops the scan it
started, the same way. A scan started by something else is left alone.

## Actions go through scripts

As in omarchy, actions do not use BlueZ's D-Bus calls from the shell:

- **`sarisarinama-bluetooth-power on|off|is-on`** moves the rfkill soft
  block. BlueZ never saves an adapter's `Powered`, so turning it off
  through BlueZ lasts until the next boot; the block is saved by
  systemd-rfkill and comes back at boot. Turning on lifts the block and,
  if bluetoothd does not power the adapter up by itself, asks it to.
- **`sarisarinama-bluetooth-device pair|connect|disconnect|forget <address>`**
  runs `bluetoothctl`, which registers an agent of its own; BlueZ needs
  one to pair, and the shell has none. Pairing also trusts the device, so
  it can connect back by itself, then connects it. Connecting turns the
  radio on first if it is off. The script exits non-zero when the device
  did not end up as asked, and the row says so (`Could not connect`) until
  the next try.

Both take `bluetoothctl` and `rfkill` from `PATH`, so they match the BlueZ
running; the Home Manager module installs them (`modules/ui/panes/bluetooth/`).
One action runs at a time.

## Keys

| Key                            | Does                                            |
| ------------------------------ | ----------------------------------------------- |
| `j` / `k`, `Ctrl+N` / `Ctrl+P`, `↓` / `↑` | Move between the switch and the devices |
| `h` / `l`                      | Move to and from Forget, on a remembered device |
| `Enter`                        | Flip the switch, or connect / disconnect / pair |
| `x` / `Delete`                 | Forget the device                               |
| `r`                            | Scan again                                      |
| `b`                            | Turn Bluetooth on or off                        |
| `Esc`                          | Close                                           |

## Files (`quickshell/panes/bluetooth/`)

| File                 | Role                                                 |
| -------------------- | ---------------------------------------------------- |
| `BluetoothPanel.qml` | PanelWindow; host contract `open`, `close`, `opened` |
| `BtState.qml`        | Adapter, rows, the scan, actions through the scripts |
| `btmodel.js`         | Rows, sections, glyphs, the words under a name; pure |
| `Hero.qml`           | The radio, its state, the power switch               |
| `DeviceList.qml`     | The sections, scrolling, following the cursor        |
| `DeviceRow.qml`      | One device; a click acts on it, ⨂ forgets it         |
| `Cursor.qml`         | `LineCursor`, plus j/k, x, r, b                      |

The bar icon is `bar/widgets/BluetoothStatus.qml`, not `Bluetooth.qml`:
that name is Quickshell.Bluetooth's own singleton.

## Looks

`style.bluetooth` is every panel's keys, from `_lib/panel.nix`; the panel
adds none. `theme.surfaces.bluetooth` is a plain panel block: a connected
device's glyph is `accent`, a failed one `urgent`. The bar icon is
`style.bar.bluetooth`, `focused` while a device is connected.

## Status

Tested headless against a mock BlueZ (python-dbusmock) on a private system
bus, with the real scripts and a stand-in `bluetoothctl` and `rfkill`:
the scan starting on open and stopping on close; connect, a failed
connect, pair, forget and disconnect from the keyboard; power off and on
with `b` and with a right click on the bar icon. The scripts are tested
on their own against fakes, and the panel was opened read-only against
the real BlueZ. Not yet used on a real screen to pair or connect.

- No audio switch: omarchy makes a Bluetooth speaker or headset the
  default output once it connects; here WirePlumber's own policy decides.
- No pairing prompts: a device asking to confirm or type a PIN pairs only
  as far as `bluetoothctl`'s own agent allows.
