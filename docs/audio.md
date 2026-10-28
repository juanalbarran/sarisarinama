# Audio panel

Every output and input PipeWire knows, with the volume of the default
one as a slider and a row per device to make another the default, then
every app playing sound with its own volume. After omarchy quattro's
`shell/plugins/panels/audio`.

```
qs -p $SARISARINAMA_PATH ipc call shell toggle audio '{}'
```

A click on the bar's speaker, or the Services menu's **Sound** row, summons
it. A right-click on the speaker mutes, as a click did before.

## Where the state comes from

`Quickshell.Services.Pipewire` (0.3.0): `Pipewire.nodes`, the defaults
`defaultAudioSink` and `defaultAudioSource`, and `PwNode.audio` for the
volume and the mute. Quickshell follows PipeWire, so nothing is polled.
A node is sorted by its flags:

| Kind   | `audio` | `isSink` | `isStream` |
| ------ | ------- | -------- | ---------- |
| output | yes     | yes      | no         |
| input  | yes     | no       | no         |
| app    | yes     | yes      | yes        |

An app is a stream that takes audio in, which is why it is a sink. A
default is chosen by writing `Pipewire.preferredDefaultAudioSink` (or
`…Source`); WirePlumber keeps the choice across restarts. Omarchy also
runs its own `omarchy-audio-*` scripts, to see through DSP chains such as
EasyEffects; this does not, see Status.

### Rows hold ids, never nodes

PipeWire deletes a node outright, and a Repeater row still holding it is
a dangling QObject that crashes the shell, as omarchy found. So the lists
handed to the panel are snapshots of `{id, name}`, taken once a burst of
changes settles, and each row looks its node up again
(`AudioState.nodeFor`). The name rides along because PipeWire reuses
ids. Nodes are bound with a `PwObjectTracker` only while the panel is
open; an unbound node has no live volume.

## Keys

`Ctrl+N`/`Ctrl+P` or `Down`/`Up` move between lines, top to bottom: the
output slider, the outputs, the input slider, the inputs, the apps. On a
slider or an app, `h`/`l` move the volume 5% and Enter mutes; on a
device, Enter makes it the default. Escape closes.

## Files (`quickshell/panes/audio/`)

| File                | Role                                                 |
| ------------------- | ---------------------------------------------------- |
| `AudioPanel.qml`    | PanelWindow; host contract `open`, `close`, `opened` |
| `AudioState.qml`    | Nodes, snapshots, volume, mute and default           |
| `audiomodel.js`     | Sorting nodes, snapshots, labels and glyphs          |
| `Hero.qml`          | The output in use, its volume, a mute switch         |
| `DeviceSection.qml` | Heading, default's slider, the devices: out or in    |
| `DeviceRow.qml`     | One device; Enter or a click makes it the default    |
| `AppList.qml`       | The `APPS` heading, a row each, a hint when empty    |
| `AppRow.qml`        | One app: name, slider, mute                          |
| `VolumeSlider.qml`  | Track, fill and knob; press or drag                  |
| `Cursor.qml`        | `LineCursor`; `slide()` takes h/l on volume lines    |

## Looks

`style.audio` is every panel's keys, from `_lib/panel.nix`, plus
`slider.height` and `slider.knob`, read by `theme/AudioStyle.qml`.
`theme.surfaces.audio` is a plain panel block: a slider paints `track`,
and `accent`, or `muted` while muted.

## Status

Written; not yet checked on screen. Things known to be open:

- No DSP awareness: with EasyEffects or a speaker tuning as the default
  output, the slider sets the level going into the processing, not the
  speakers'.
- A virtual source with no typed `audio` (EasyEffects' microphone) is not
  listed; omarchy reaches those through `wpctl`.
- The panel does not scroll; many apps at once make it tall.
- Volume above 100% shows its number but the slider stops at the end.
