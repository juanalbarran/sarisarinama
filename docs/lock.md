# Lock screen

The session lock, hosted by the shell as omarchy quattro's
`shell/plugins/lock` is. Password only: no fingerprint, no screen
blanking. Each screen shows the time, the date and one password field, over
the desktop's wallpaper, blurred and dimmed.

```
qs -p $SARISARINAMA_PATH ipc call lock lock
qs -p $SARISARINAMA_PATH ipc call lock status
```

`status` answers `{"locked", "secure", "pam"}`. `lock` answers `ok`, or
`missing-pam` and locks nothing, see [PAM](#pam).

## How it locks

`WlSessionLock`, the Wayland ext-session-lock protocol, which Sway and
Hyprland both speak. While locked the compositor draws only the lock's
surfaces, one per screen, and keeps them up if the shell dies: a lock is
released by an unlock, never by a crash. `secure` turns true once every
screen shows its surface; only then is the session hidden.

`WlSessionLock.locked`, set from QML, does not notify a binding over it
(quickshell 0.3.0), so `LockScreen` reads it afresh through `isLocked()`
instead of exposing a property.

## Triggers

Three, all in the shell, so no swayidle is needed:

| Trigger                    | Heard through                                  |
| -------------------------- | ---------------------------------------------- |
| `loginctl lock-session`    | logind's `Lock` signal for this session        |
| Idle for `lock.idle` s     | `IdleMonitor` (ext-idle-notify)                |
| The machine about to sleep | logind's `PrepareForSleep`, under an inhibitor |

The system menu's **Lock** row runs `loginctl lock-session`
(`systemMenu.lockCommand`), so it is the first trigger.

logind is heard by `sarisarinama-lock-events`, which the shell runs and
restarts. It holds a logind _delay inhibitor_ for sleep and watches with
`dbus-monitor`, printing `lock` or `sleep` on stdout. After `sleep` it
waits for one line on stdin, written once the lock is secure, then exits:
the inhibitor goes with it and the suspend proceeds. It waits at most 4 s,
inside logind's default `InhibitDelayMaxSec` of 5. With no PAM service the
shell answers at once, so a suspend is never held for a lock that cannot
happen. Ported from omarchy's `omarchy-system-sleep-monitor`, which runs as
a systemd unit; here the shell is the supervisor.

`lock.idle` is seconds without input, 300 by default; `0` never locks on
idle. An app that inhibits idle, a full-screen video say, holds it off.
`IdleMonitor` keeps the timeout it started with, and `lock.json` is read
after startup, so `IdleLock` builds a new monitor for every new value.

## Keys

Enter checks the password, Escape or Ctrl+U clears it. A click anywhere
gives the field its focus back. A wrong password turns the border and the
hint `urgent`; typing clears it.

## PAM

The password is checked by PAM, service `sarisarinama-lock`. Without
`/etc/pam.d/sarisarinama-lock` the lock refuses to lock: nothing could
unlock it. The shell watches the file, so it notices one written later.

- **NixOS**: import `modules.nixos.sarisarinama` in the system config. It
  declares `security.pam.services.sarisarinama-lock`, NixOS's default
  stack; Home Manager cannot write to `/etc` there.
- **Another distribution**: Home Manager activation writes it with sudo,
  when `lock.pam.enable` is on (default: `targets.genericLinux.enable`).
  Quickshell from Nix links Nix's libpam, which does not understand
  Ubuntu's `@include`, so the file is the single line
  `auth include common-auth`. Its `pam_unix` runs
  `/run/wrappers/bin/unix_chkpwd`, a NixOS path, so a tmpfiles rule links
  it to `/sbin/unix_chkpwd`. Ported from canaima main's swaylock module.

## Files

| File                                  | Role                                        |
| ------------------------------------- | ------------------------------------------- |
| `quickshell/lock/LockScreen.qml`      | The session lock, its state, the `lock` IPC |
| `quickshell/lock/LockAuth.qml`        | One PAM conversation per password           |
| `quickshell/lock/LockView.qml`        | One screen: time, date, field               |
| `quickshell/lock/IdleLock.qml`        | `IdleMonitor` over `lock.idle`              |
| `quickshell/lock/LogindLock.qml`      | Runs `sarisarinama-lock-events`             |
| `quickshell/theme/LockStyle.qml`      | The `lock` section of `style.json`          |
| `quickshell/theme/LockColors.qml`     | The `lock` block of `surfaces.json`         |
| `modules/ui/lock/events.nix`          | `sarisarinama-lock-events`                  |
| `modules/ui/lock/_lib/lock-events.sh` | Its script                                  |
| `modules/ui/lock/idle.nix`            | `lock.idle`                                 |
| `modules/ui/lock/render.nix`          | Writes `lock.json`                          |
| `modules/ui/lock/pam.nix`             | `lock.pam.enable`, the sudo activation      |
| `modules/ui/lock/nixos.nix`           | The NixOS PAM service                       |
| `modules/ui/style/lock.nix`           | `style.lock.*`                              |

## Looks

Behind everything, the wallpaper the desktop shows (`Wallpapers.current`,
see [themes](./themes.md#switching-wallpapers)), blurred as omarchy's is,
under a wash so the time and the field stay readable. With no wallpaper,
the `background` colour alone.

`style.lock`: the shared font and scale, `gap` between the rows,
`clockSize` (px, display type outside the type scale), `blur` (px, 64; 0
keeps the image sharp) and `field` (`width`, `height`, `paddingX`,
`radius`, `border`).

`theme.surfaces.lock`: `background` (keep its alpha at 1, or the desktop
shows through), `dim` and `dimAlpha` (the wash, `background` at 0.45),
`text`, `muted` (the date and the hint), `field`, `fieldBorder` and
`urgent`. From omarchy's `[lock]`, without its selection colour or its
active border.

## Status

Written and tested off screen; not yet used for real.

- In a headless Sway: locking, `secure`, a wrong and a right password
  (pam_deny, pam_permit), the refusal without PAM, all three triggers with
  a fake `sarisarinama-lock-events`, and the view rendered to an image.
- On Ubuntu with Nix's libpam: a wrong password is rejected through the
  real `common-auth`.
- Against the real logind: the inhibitor is taken, and a real
  `loginctl lock-session` reaches the script. As a user `dbus-monitor`
  cannot become a monitor and falls back to eavesdropping; signals still
  arrive.
- Never run: a real suspend, the right password through the real PAM
  stack, several screens.
- If the shell crashes while locked, the screen stays locked. The way out
  is a TTY: end Sway, or start another locker against the session.
