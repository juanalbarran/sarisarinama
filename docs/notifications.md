# Notifications

The shell as the notification daemon: it owns
`org.freedesktop.Notifications` on the session bus, so `notify-send` and
every app that speaks the freedesktop protocol (libnotify, browsers, chat
apps) is drawn as a toast in the top-right corner. A history panel behind
the bar's bell lists what arrived, with Do Not Disturb. After omarchy
quattro's `shell/plugins/notifications/` and its `docs/notifications.md`.

This is the first step of [#28](https://github.com/juanalbarran/sarisarinama/issues/28):
toasts, the history, Do Not Disturb, the bell and IPC. Grouped stacks,
per-app snooze, inline replies, persistence across restarts and code or
link detection are later steps; the issue lists what each means.

## Turning it on

Off by default, because only one daemon can own the bus name and another
(dunst, mako, swaync) may have it:

```nix
programs.sarisarinama.notifications.enable = true;
```

Stop the other daemon first. While one holds the name the shell receives
nothing. A daemon started by D-Bus activation (dunst's
`org.knopwob.dunst.service`) comes back only if nothing owns the name, so
once the shell has it, it keeps it.

The option is written to `~/.config/sarisarinama/notifications.json`, and
the shell claims the name as soon as the file says `enable`. Turning it
off takes a shell restart: Quickshell's server keeps the name once taken.

## Toasts

Newest on top, at most `style.notifications.toast.max` (5) on screen; the
rest wait their turn without counting down. Timings are omarchy's:

| Urgency  | Stays                                            |
| -------- | ------------------------------------------------ |
| low      | 5 s, or up to 30 s if the sender asks for longer |
| normal   | 8 s, or up to 30 s if the sender asks for longer |
| critical | until dismissed; drawn in the `urgent` colour    |

The countdown pauses under the pointer, and an update from the sender
(`replaces_id`, e.g. `notify-send -r`) restarts it in place.

| Mouse             | Does                                             |
| ----------------- | ------------------------------------------------ |
| left click        | the sender's default action, else just closes it |
| middle click, `󰅖` | closes it                                        |
| a button          | that action, then closes it                      |

The sender hears why it closed: expired (1), dismissed (2), or closed by
itself (3). The body is drawn as plain text: the server does not offer
markup, and tags a sender sends anyway are stripped.

The icon is the first that loads of: the sender's picture (an image sent
as data, or a file), the app's icon from the icon theme (`app_icon`,
`-i`, or the desktop entry), then the app's first letter on a tile.

## Do Not Disturb

While on, a notification goes to the history instead of the screen. Two
exceptions, as in omarchy:

- `notify-send -u critical` (app name `notify-send`, urgency critical) gets
  through: a bare CLI emergency. Critical alone is not enough, because chat
  apps send critical to force themselves on screen.
- A bare `notify-send` that is not critical, or anything with the
  `transient` hint, is dropped instead of kept: nobody looks back at it.

Do Not Disturb lives in memory; a shell restart turns it off.

## The bell and the panel

The bell (`Bell.qml`) is hidden unless the shell is the daemon. It shows
a badge while there are notifications the panel has not shown, and is
crossed out under Do Not Disturb. A click opens the panel, a right click
flips Do Not Disturb (as a right click on the speaker mutes).

The panel lists the history, newest first, up to 100 entries: app, age,
summary and the first lines of the body. A dot marks one still on screen.
Opening it marks everything read.

| Key                            | Does                                          |
| ------------------------------ | --------------------------------------------- |
| `j` / `k`, `Ctrl+N` / `Ctrl+P` | Move between the switch and the notifications |
| `Enter`                        | Flip the switch, or run a shown one's action  |
| `x` / `Delete`                 | Forget the notification (closing it if shown) |
| `c`                            | Forget them all, closing every toast          |
| `d`                            | Flip Do Not Disturb                           |
| `Esc`                          | Close                                         |

A click on a shown notification runs its action, a middle click forgets
it. The history is in memory only, like Do Not Disturb.

## IPC

```
qs -p $SARISARINAMA_PATH ipc call shell toggle notifications '{}'
qs -p $SARISARINAMA_PATH ipc call notifications toggleDnd
```

The `notifications` target answers:

| Method           | Does                                     |
| ---------------- | ---------------------------------------- |
| `dndState`       | `on` or `off`                            |
| `toggleDnd`      | flips it, answers the new state          |
| `setDnd on\|off` | sets it                                  |
| `dismissOne`     | closes the newest toast (`none` if none) |
| `dismissAll`     | closes every toast, answers how many     |
| `invokeLast`     | the newest toast's default action        |
| `count`          | toasts on screen                         |
| `clear`          | forgets the history                      |

## Files

`quickshell/notifications/`, the daemon and the toasts:

| File                     | Role                                                        |
| ------------------------ | ----------------------------------------------------------- |
| `NotificationCenter.qml` | Singleton: the server, toasts, history, DND, the IPC target |
| `notifmodel.js`          | Timings, the quiet rules, a notification as a row; pure     |
| `ToastStack.qml`         | The top-right window; only the cards take the pointer       |
| `Toast.qml`              | One toast: icon, app, summary, body, buttons, countdown     |
| `NoticeIcon.qml`         | Picture, theme icon or letter; shared with the panel        |

`quickshell/panes/notifications/`, the panel:

| File                     | Role                                                 |
| ------------------------ | ---------------------------------------------------- |
| `NotificationsPanel.qml` | PanelWindow; host contract `open`, `close`, `opened` |
| `Hero.qml`               | Bell, count or DND, the DND switch                   |
| `HistoryList.qml`        | The history, scrolling, following the cursor         |
| `HistoryRow.qml`         | One notification                                     |
| `Cursor.qml`             | `LineCursor`, plus j/k, x, c, d                      |

Live `Notification` objects are kept in a plain map, never a model role:
the sender may close one at any time, and a role would dangle (omarchy's
finding). What draws a notification gets a plain row
(`notifmodel.js` `snapshot`).

And `modules/ui/notifications/`: `options.nix` (`enable`) and `render.nix`
(`notifications.json`).

## Looks

`style.notifications` is every panel's keys from `_lib/panel.nix` for the
panel, with a card 420 px wide, plus:

| Key                                | Default   | Meaning                                |
| ---------------------------------- | --------- | -------------------------------------- |
| `toast.width`                      | 380       | Toast width                            |
| `toast.padding`, `.gap`, `.margin` | 12, 8, 12 | Inside, between toasts, from the edges |
| `toast.iconSize`                   | 40        | Toast icon                             |
| `toast.radius`, `.border`          | 8, 2      | Not scaled                             |
| `toast.bodyLines`                  | 3         | Body lines before it is cut            |
| `toast.max`                        | 5         | Toasts on screen at once               |
| `history.maxHeight`, `.iconSize`   | 420, 28   | Panel list height, its icons           |

`theme.surfaces.notifications` is a plain panel block; the toasts paint
from it too: `background`, `border` (`urgent` on a critical one), `text`,
`muted`, and `accent` for the icon tile. The bell is `style.bar.bell`.

## Status

Tested headless on a private session bus with real `notify-send` senders:
the shell owns the name only when enabled; default action, a button and
the ✕ by pointer, middle click; expiry timings and the close reasons the
sender sees; a sender closing its own; replace in place; Do Not Disturb
and its critical exception; seven at once with five shown; the panel's
keys. Not yet used on a real screen, and dunst still owns the name on the
desktop.

- Turning `enable` off takes a shell restart (see above).
- One screen: the toasts open on the default one, like the bar.
- No persistence, snooze, grouping or inline replies yet (#28's later steps).
