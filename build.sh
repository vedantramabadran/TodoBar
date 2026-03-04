#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building TodoBar..."

rm -rf TodoBar.app
mkdir -p TodoBar.app/Contents/MacOS
mkdir -p TodoBar.app/Contents/Resources

swiftc \
    -swift-version 5 \
    -framework Cocoa \
    -framework Carbon \
    Sources/main.swift \
    Sources/Constants.swift \
    Sources/TaskStore.swift \
    Sources/OverlayPanel.swift \
    Sources/AppDelegate.swift \
    Sources/ContentView.swift \
    -o TodoBar.app/Contents/MacOS/TodoBar

cp Info.plist TodoBar.app/Contents/Info.plist

echo ""
echo "Done! Built TodoBar.app"
echo ""
echo "  Run:      open ~/TodoBar/TodoBar.app"
echo "  Shortcut: Ctrl+Option+T  — toggle the overlay"
echo "  Escape    — hide the overlay"
echo "  Menu bar: click the checklist icon to toggle"
