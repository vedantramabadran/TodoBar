import Cocoa
import Carbon
import SwiftUI

// Free C-compatible function for the Carbon hotkey callback
private func hotKeyCallback(
    _ nextHandler: EventHandlerCallRef?,
    _ event: EventRef?,
    _ userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let ptr = userData else { return OSStatus(eventNotHandledErr) }
    let delegate = Unmanaged<AppDelegate>.fromOpaque(ptr).takeUnretainedValue()
    DispatchQueue.main.async { delegate.toggleOverlay() }
    return noErr
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var overlayPanel: OverlayPanel!
    var hotKeyRef: EventHotKeyRef?
    var hotKeyEventHandler: EventHandlerRef?
    let taskStore = TaskStore()
    var previousApp: NSRunningApplication?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        setupOverlayPanel()
        registerHotKey()

        NotificationCenter.default.addObserver(
            forName: .hidePanel,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.hidePanel()
        }
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "TodoBar")
            button.action = #selector(toggleOverlay)
            button.target = self
        }
    }

    func setupOverlayPanel() {
        guard let screen = NSScreen.main else { return }

        let panelWidth: CGFloat  = 420
        let panelHeight: CGFloat = 680
        let margin: CGFloat      = 20

        let x = screen.visibleFrame.maxX - panelWidth - margin
        let y = screen.visibleFrame.maxY - panelHeight - margin
        let frame = NSRect(x: x, y: y, width: panelWidth, height: panelHeight)

        overlayPanel = OverlayPanel(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        overlayPanel.isOpaque = false
        overlayPanel.backgroundColor = .clear
        overlayPanel.level = .floating
        overlayPanel.collectionBehavior = [.canJoinAllSpaces, .stationary]
        overlayPanel.isMovableByWindowBackground = true
        overlayPanel.hasShadow = false

        let contentView = ContentView(taskStore: taskStore)
            .environment(\.colorScheme, .dark)
        overlayPanel.contentView = NSHostingView(rootView: contentView)
    }

    func registerHotKey() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyCallback,
            1,
            &eventType,
            selfPtr,
            &hotKeyEventHandler
        )

        let hotKeyID = EventHotKeyID(signature: OSType(0x544F444F), id: UInt32(1))
        // Shortcut: Ctrl + Option + T
        RegisterEventHotKey(
            UInt32(kVK_ANSI_T),
            UInt32(controlKey | optionKey),
            hotKeyID,
            GetApplicationEventTarget(),
            OptionBits(0),
            &hotKeyRef
        )
    }

    @objc func toggleOverlay() {
        if overlayPanel.isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }

    func showPanel() {
        previousApp = NSWorkspace.shared.frontmostApplication
        NSApp.activate(ignoringOtherApps: true)
        overlayPanel.makeKeyAndOrderFront(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            NotificationCenter.default.post(name: .focusInput, object: nil)
        }
    }

    func hidePanel() {
        overlayPanel.orderOut(nil)
        previousApp?.activate(options: [])
        previousApp = nil
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let ref = hotKeyRef { UnregisterEventHotKey(ref) }
    }
}
