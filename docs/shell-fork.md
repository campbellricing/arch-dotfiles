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
| `modules/dashboard/dash/User.qml` | Drop `"up "` prefix from uptime; replace WM icon/name row with custom text ("B-baka…") |
| `modules/drawers/Interactions.qml` | Add `osdShowOnHover` / `utilitiesShowOnHover` switches (both `false`) — upstream hardcodes open-on-hover for the OSD and utilities panels |
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
