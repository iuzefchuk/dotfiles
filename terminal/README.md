# Terminal.app

`Basic.terminal` is an export of the **Basic** profile.

**Install the font first.** The profile references the font by name only; if it is not
installed, Terminal silently substitutes a default and the profile looks wrong for a
reason that is not obvious from anywhere in the UI:

```sh
brew install --cask font-sf-mono-nerd-font-ligaturized
```

Then import:

```sh
open Basic.terminal
```

then set it as default in **Terminal → Settings → Profiles → Basic → Default**.

## What is actually customized

Terminal only stores keys that differ from its built-in defaults. For this profile
that is just:

| key | value | where in the UI |
|---|---|---|
| `Font` | `LigaSFMonoNerdFont-Regular`, 12pt | Profiles → Text → Font |
| `BackgroundColor` | system `textBackgroundColor` | Profiles → Text → Background |
| `FontAntialias` | on | Profiles → Text |
| `FontWidthSpacing` | 1.004 | Profiles → Text → Character spacing |

Everything else is Terminal's default.

## Why the background is a *system* color

`BackgroundColor` is stored as the named catalog color `System / textBackgroundColor`
rather than as RGB components. That is deliberate: named system colors are dynamic, so
the background follows the macOS light/dark appearance automatically — matching the
text color, which uses the system `textColor` by virtue of not being overridden at all.

Picking any colour from the normal colour wheel writes fixed RGB components instead and
breaks this: the text keeps flipping with the appearance while the background stays put.
To set it back, open the Background colour well and choose
**Color Palettes → Developer → textBackgroundColor**.

## Caveat on diffing this file

Font and colour are stored as base64 `NSKeyedArchiver` blobs, so a one-shade change
produces an unreadable wall of changed base64 in `git diff`. Treat `Basic.terminal` as a
restore artifact and keep the table above as the readable record — if you change a
setting, update both.

## Re-exporting after a change

GUI: **Settings → Profiles → select Basic → ⚙︎ gear menu → Export…**

Or:

```sh
/usr/bin/python3 -c "
import plistlib, subprocess, os
d = plistlib.loads(subprocess.run(['defaults','export','com.apple.Terminal','-'],capture_output=True).stdout)
p = os.path.expanduser('~/Code/dotfiles/terminal/Basic.terminal')
open(p,'wb').write(plistlib.dumps(d['Window Settings']['Basic']))
"
```

Terminal writes its preferences on quit, so quit Terminal before re-exporting if you
want the very latest state.
