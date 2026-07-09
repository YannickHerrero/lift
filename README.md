# lift.

A minimalist iOS workout tracker. All data is stored on the device — no
account, no sync, no network.

## Screens

- **home** — start/resume a session, jump to history or stats
- **session** — log sets per exercise with a snapping weight/reps wheel,
  see what you did last time, and run a rest timer
- **history** — month calendar with a dot per training day; tap a day for
  the full recap
- **stats** — sessions per week, tonnage trend, per-exercise best-set
  progress and all-time totals
- **settings** — light/dark theme, kg step, wheel max weight, auto-rest,
  and the exercise catalog

## Building

The Xcode project is generated with [XcodeGen](https://github.com/yonas/XcodeGen):

```sh
xcodegen generate
xcodebuild -project Lift.xcodeproj -scheme Lift \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro" build
```

Requires iOS 17+.

## Debug helpers

Debug builds accept launch arguments to reproduce app states for
screenshots (all no-ops in release):

```sh
# ~2 months of deterministic demo history
... -seed-demo
# jump straight to a screen / open a sheet / force a theme
... -screen stats -theme dark
... -screen session -sheet picker-kg
```

## Storage

Two JSON files in the app's Documents directory:

- `lift-data.json` — theme, prefs, exercises, finished sessions
- `lift-active.json` — the in-progress session, so a workout survives a
  relaunch
