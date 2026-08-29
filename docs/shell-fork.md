# Caelestia shell fork

`quickshell/caelestia/` in this repo is a **vendored, modified copy** of the
[caelestia-shell](https://github.com/caelestia-dots/shell) package
(AUR: `caelestia-shell`).

## How it works

Quickshell looks for configs in `~/.config/quickshell/` before `/etc/xdg/quickshell/`,
so this copy **always wins** over the installed package. Consequences:

- Package updates (`yay -Syu`) **never change the running shell** — nothing breaks,
  but upstream fixes/features don't arrive on their own.
- The package still matters: it pulls in the runtime dependencies
  (`quickshell-git`, `python-materialyoucolor`, `libcava`, fonts, …) and provides
  the pristine upstream copy at `/etc/xdg/quickshell/caelestia` to diff against.
- Keep the package installed even though its QML is shadowed.

## After a caelestia-shell package update

```sh
scripts/diff-shell.sh            # list files that differ
scripts/diff-shell.sh -u         # full diff
scripts/diff-shell.sh modules/lock/Pam.qml   # one file
```

Review what upstream changed and cherry-pick anything you want into
`~/.config/quickshell/caelestia/`. Files that are *not* listed below but show
up as DIFF were changed by upstream only — you can usually copy them over
verbatim from `/etc/xdg/quickshell/caelestia/`.

## Intentional local modifications (vs caelestia-shell 2.1.0)

| File | Change |
|---|---|
| `modules/bar/Bar.qml` | Click-to-open panels (see note below): add `togglePopout()`/`setPopout()` (click a status/tray icon to toggle its popout); add `notifs` + `controlcenter` bar entries (opt-in via `shell.json` `bar.entries`; currently `enabled: false`) |
| `modules/bar/BarWrapper.qml` | Click-to-open panels: forward `togglePopout()` to `Bar`; keep the bar visible while a popout is open (`shouldBeVisible \|\| popouts.hasCurrent`) so click-mode popouts don't detach from a non-persistent bar |
| `modules/bar/components/Clock.qml` | Click-to-open panels: `MouseArea` toggling the dashboard |
| `modules/bar/components/ControlCenter.qml` | **New file.** Bar button (icon `tune`) toggling the control-center / utilities panel — used by the `controlcenter` bar entry |
| `modules/bar/components/Notifications.qml` | **New file.** Bar button (icon `notifications`) toggling the notifications / sidebar panel — used by the `notifs` bar entry (named `Notifications` not `Notifs` to avoid colliding with the `services/Notifs.qml` singleton) |
| `modules/bar/components/Tray.qml` | Click-to-open panels: pass `bar` through to `TrayItem` |
| `modules/bar/components/TrayItem.qml` | Click-to-open panels: right-click opens the tray item's menu as a popout (was `secondaryActivate()`, now moved to middle-click) |
| `modules/dashboard/dash/User.qml` | Drop `"up "` prefix from uptime; replace WM icon/name row with custom text ("B-baka…") |
| `modules/drawers/ContentWindow.qml` | Click-to-open panels: focus grab (close-on-click-outside) also covers the utilities panel and click-mode bar popouts; `onCleared` also hides utilities |
| `modules/drawers/Interactions.qml` | Add `osdShowOnHover` / `utilitiesShowOnHover` / `popoutsShowOnHover` switches (all `false`) — upstream hardcodes open-on-hover for the OSD, utilities and bar-icon popouts. `popoutsShowOnHover: false` routes bar status/tray icon clicks to `bar.togglePopout()` instead |
| `modules/launcher/AppList.qml` | Bug fix: bind `model.values` directly instead of via `PropertyChanges` — state transitions left the binding dead, freezing launcher search results |
| `modules/lock/center/ProfilePic.qml` | Smaller (0.5× instead of 0.7×) circular avatar instead of clam-shell shape |
| `modules/lock/Content.qml` | Uniform `extraLarge` corner radius |
| `modules/lock/Fetch.qml` | Title "caelestia" instead of "caelestiafetch.sh"; hide uptime + battery lines; `extraLarge` radius |
| `modules/lock/NotifDock.qml` | `extraLarge` radius |
| `modules/lock/NotifGroup.qml` | `extraLarge` radius |
| `modules/lock/Pam.qml` | Fingerprint: silently retry on errors (e.g. idle timeout) instead of flashing "FP ERROR" |
| `modules/lock/weather/Forecast.qml` | `extraLarge` radius |
| `modules/lock/WeatherInfo.qml` | `extraLarge` radius |

Theme note: most lock-screen changes are "make every card radius
`Tokens.rounding.extraLarge`" — if upstream refactors those files, re-applying
is mechanical.

Fingerprint auth on the lock screen uses the PAM config shipped in
`quickshell/caelestia/assets/pam.d/fprint` (loaded by `Pam.qml` directly —
no `/etc/pam.d` changes needed) and requires the `python-validity` +
`open-fprintd` + `fprintd-clients-git` + `pam-fprint-grosshack` stack with an
enrolled finger (`fprintd-enroll`).
