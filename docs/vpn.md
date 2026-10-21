# VPN panel

Every VPN profile NetworkManager knows, with a switch to bring each one up
or down. A plugin VPN (OpenVPN, OpenConnect…) has type `vpn`, a WireGuard
tunnel `wireguard`; both are listed. Omarchy quattro has no VPN in its
network panel; it ships Tailscale as a panel of its own, and this follows
the same split.

```
qs -p $SARISARINAMA_PATH ipc call shell toggle vpn '{}'
```

A click on the bar's VPN icon, or the Services menu's **VPN** row, summons it.

## Where the state comes from

Quickshell's `Networking` (0.3.0) knows Wi-Fi and wired devices only, so
the panel asks `nmcli` instead:

```
nmcli -t -f NAME,UUID,TYPE,STATE connection show
```

when it opens, after every change, and every 3 s while it is open, which
is how a tunnel that drops shows up. A change is
`nmcli --wait 30 connection up|down uuid <uuid>`, passed as arguments,
never through a shell. Profiles are named by UUID, since two can share a
name. `nmcli` comes from `PATH`, so it is the one that matches the
NetworkManager actually running.

One change at a time: while one runs, its switch shows where it is going
and every other switch is greyed out. A change that fails shows nmcli's
error on its row until the next one.

## Keys

`Ctrl+N`/`Ctrl+P` move between profiles, Enter brings the one under the
cursor up or down, `r` reads the profiles again, Escape closes. The
connected profile is listed first, and the cursor starts on it.

## Files (`quickshell/panes/vpn/`)

| File           | Role                                                     |
| -------------- | -------------------------------------------------------- |
| `VpnPanel.qml` | PanelWindow; host contract `open`, `close`, `opened`     |
| `VpnState.qml` | Profiles from nmcli, `toggle(uuid)`, polling             |
| `vpnmodel.js`  | Parses nmcli's terse output; icon and labels             |
| `Hero.qml`     | Icon, connected profile, state                           |
| `VpnList.qml`  | The `PROFILES` heading, one row each, a hint when empty  |
| `VpnRow.qml`   | Name, type or error, and the switch                      |
| `Cursor.qml`   | `LineCursor`, one line per profile; `r` refreshes        |

## Looks

`style.vpn` and `theme.surfaces.vpn` are every panel's keys, from the two
`_lib/panel.nix`; the VPN panel adds none, like the monitor panel.

## Status

Written; not yet checked on screen. Things known to be open:

- No profile has been brought up from the panel yet. A dummy one to try it
  with: `nmcli connection add type wireguard ifname wg-test con-name test-vpn`.
- An OpenVPN profile that asks for a password needs a NetworkManager secret
  agent (nm-applet, say). Without one, `up` fails with a secrets error,
  shown on the row. WireGuard keeps its key in the profile and needs none.
- The bar shows only whether a tunnel is up, not which one.
