# TodoBar

A minimal macOS menu bar todo app built with Swift and SwiftUI.

## Features

- Lives in your menu bar — no Dock icon
- Floating dark overlay panel that appears over any app
- Add tasks, check them off, and they disappear automatically
- Tasks persist across sessions via `UserDefaults`
- Global hotkey to toggle the panel from anywhere

## Usage

| Action | How |
|---|---|
| Toggle panel | `Ctrl + Option + T` or click the checklist icon in the menu bar |
| Add a task | Type in the input field and press `Return` |
| Complete a task | Click the circle next to it |
| Hide panel | Press `Escape` |

## Building

Requires macOS with Xcode command line tools installed.

```bash
./build.sh
```

Then run:

```bash
open ~/TodoBar/TodoBar.app
```

## Project Structure

```
Sources/
  main.swift         # Entry point
  AppDelegate.swift  # Menu bar item, hotkey, panel setup
  ContentView.swift  # SwiftUI task list UI
  TaskStore.swift    # Task data model and persistence
  OverlayPanel.swift # Floating NSPanel subclass
  Constants.swift    # Shared notification names
```
