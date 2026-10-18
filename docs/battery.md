# Battery panel

The charge, where it is going and how fast, and the power profile, after
omarchy quattro's `shell/plugins/panels/power`. It opens only on a machine
with a laptop battery, the same test as the bar's widget.

```
qs -p $SARISARINAMA_PATH ipc call shell toggle battery '{}'
```

A click on the bar's battery summons it; the root menu has no row for it.

## Where the state comes from

Omarchy runs its own scripts (`omarchy-battery-status`,
`omarchy-powerprofiles-list`); this reads the two D-Bus services directly,
through `Quickshell.Services.UPower` (0.3.0):

- `UPower.displayDevice`: `percentage` (0..1), `state`, `energyCapacity`
  (Wh), `changeRate` (W), `timeToEmpty` and `timeToFull` (s),
  `healthPercentage`.
- `PowerProfiles`: `profile`, writable, `hasPerformanceProfile` and
  `degradationReason`.

Quickshell follows both services, so nothing is polled. UPower has no
charge-cycle count, so health stands where omarchy shows cycles.
Performance is offered only where the hardware has it; when the daemon
holds it back (heat, a lap) the heading says why, in red.

## Keys

`h`/`l` move between profiles, Enter applies the one under the cursor,
Escape closes. The cursor starts on the profile in force.

## Files (`quickshell/panes/battery/`)

| File               | Role                                                 |
| ------------------ | ---------------------------------------------------- |
| `BatteryPanel.qml` | PanelWindow; host contract `open`, `close`, `opened` |
| `BatteryState.qml` | UPower and PowerProfiles, `setProfile(id)`           |
| `batmodel.js`      | Icons, durations, watts, the profile list            |
| `Hero.qml`         | Icon, status, the charge in large type               |
| `ChargeBar.qml`    | Track and fill; red at 15% or less on battery        |
| `Stats.qml`        | Capacity, health, time left or to full, rate         |
| `Cursor.qml`       | `LineCursor`, one line: the profile pills            |

## Looks

`style.battery` is every panel's keys, from `_lib/panel.nix`, plus
`charge.height` and `charge.animation` (ms, not scaled), read by
`theme/BatteryStyle.qml`. `theme.surfaces.battery` is a plain panel block:
the bar paints `track`, `accent` and `urgent`.

## Status

Written; not yet checked on screen. Things known to be open:

- UPower and power-profiles-daemon must be enabled in the NixOS config,
  see [prerequisites](./prerequisites.md).
- What `PowerProfiles.profile` reads with no daemon running is unchecked.
- That `healthPercentage` is 0..100, unlike `percentage`, is taken on trust.
