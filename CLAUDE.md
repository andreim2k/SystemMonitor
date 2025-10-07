# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SystemMonitor is a macOS menu bar application that displays real-time system metrics (CPU, Memory, Network, Disk) using SwiftUI and native macOS APIs. The app runs as an accessory (menu bar only) with a liquid glass UI design and integrates directly with macOS system calls for metrics collection.

## Build Commands

```bash
# Build the project
swift build

# Build release version
swift build -c release

# Build and install as app bundle
./build_app.sh

# Run all tests
./run_tests.sh
# Or: swift test

# Run specific test suite
swift test --filter SystemMetricsTests
swift test --filter MenuBarControllerTests
swift test --filter ViewTests
swift test --filter IntegrationTests
```

## Project Structure

The project has TWO separate codebases that must be kept in sync:

### 1. Swift Package Manager (SPM) Version
- **Location**: `Sources/SystemMonitor/`
- **Entry Point**: `Sources/SystemMonitor/main.swift`
- **Purpose**: Command-line executable build, testing, development
- **Architecture**: Manual AppKit-based setup with `NSApplication` and `AppDelegate`

### 2. Xcode Project Version
- **Location**: `SystemMonitor/` directory
- **Entry Point**: `SystemMonitor/SystemMonitorApp.swift`
- **Purpose**: Standard macOS app bundle with Xcode
- **Architecture**: SwiftUI `@main` with `MenuBarExtra`

**CRITICAL**: When modifying core components (`SystemMetrics.swift`, `SystemMonitorView.swift`, view components), changes must be duplicated in BOTH:
- `Sources/SystemMonitor/` (SPM version)
- `SystemMonitor/` (Xcode version)

The two versions have different entry points but share identical business logic and UI code.

## Core Architecture

### SystemMetrics (Core Data Layer)
**File**: `Sources/SystemMonitor/SystemMetrics.swift` (also duplicated in `SystemMonitor/SystemMetrics.swift`)

- `ObservableObject` that polls system metrics every 1 second using a `Timer`
- **CPU**: Uses `sysctlbyname("vm.loadavg")` and converts load average to percentage
- **Memory**: Uses `host_statistics64` with `HOST_VM_INFO64` to get VM statistics
- **Network**: Parses `netstat -ibn` output for en0 interface (main network interface only)
- **Disk**: Uses `FileManager` resource values for volume capacity
- Maintains 60-second history arrays for all metrics
- All updates happen on main thread via `DispatchQueue.main.async`

**Network Monitoring Details**:
- Uses `Process` to run `/usr/bin/netstat -ibn`
- Filters for "en0" interface only (avoids virtual/tunnel interfaces)
- Calculates delta between polls and divides by time interval
- Caps values at 1000 MB/s to prevent overflow/wraparound issues
- Resets to 0 if counter rollover detected (negative delta or >1000 MB/s)

### MenuBarController (SPM Version Only)
**File**: `Sources/SystemMonitor/MenuBarController.swift`

- Manages `NSStatusItem` for menu bar display
- Creates custom `NSImage` with SF Symbols and text for all metrics
- Handles popover presentation when menu bar item is clicked
- Uses Combine to subscribe to SystemMetrics updates
- Menu bar format: `[CPU icon]X% [Network icon]↑X/↓X [Disk icon]XGB`
- Disk shows FREE space in GB (not usage percentage)

### SystemMonitorView (UI Layer)
**File**: `Sources/SystemMonitor/SystemMonitorView.swift`

Contains all SwiftUI view components:
- `LiquidGlassMenuView`: Main popover content (360×400px)
- `LiquidGlassMetricCard`: Reusable metric card with icon, value, title
- `LiquidGlassNetworkCard`: Special network card showing upload/download
- `LiquidGlassDiskCard`: Shows free space and total capacity
- `LiquidGlassButtonStyle`: Custom button style for quit button
- `liquidGlassBackground()`: Shared background style function

**UI Design**:
- Uses `.ultraThinMaterial` for glass morphism effect
- Animated gradients and pulsing icons
- 6 floating particle effects for visual polish
- Cards use color-coded themes: Orange (CPU), Green (Memory), Blue (Network), Purple (Disk)

### Entry Points

**SPM Version** (`Sources/SystemMonitor/main.swift`):
```swift
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)  // Menu bar only
app.run()
```

**Xcode Version** (`SystemMonitor/SystemMonitorApp.swift`):
```swift
@main
struct SystemMonitorApp: App {
    var body: some Scene {
        MenuBarExtra { ... } label: { ... }
        .menuBarExtraStyle(.window)
    }
}
```

## Key Implementation Details

### Menu Bar Rendering
The menu bar displays metrics by creating a single `NSImage` that contains:
1. SF Symbol icons (using `NSImage.SymbolConfiguration`)
2. Monospaced system font text
3. Precise spacing calculations (5px between icon and text, 12px between groups)
4. Disk icon has 8px spacing (3px extra) per design requirement
5. Image is set as template (`.isTemplate = true`) to adapt to menu bar appearance

### Metric Formatting
- CPU/Memory/Disk: Show as percentages with 1 decimal place
- Network: Shows as MB/s with 1 decimal place, separate upload/download
- Disk (menu bar): Shows FREE space in GB as integer
- Disk (popover): Shows "X GB of Y GB" format using `ByteCountFormatter`

### Performance Considerations
- Timer-based polling at 1 second intervals (not real-time)
- History limited to 60 data points (1 minute)
- Network stats only update if >0.5 seconds elapsed (prevents jitter)
- All UI updates on main thread
- Popover uses `.transient` behavior (auto-dismisses)

## Testing

The test suite is comprehensive with 5 main files in `Tests/SystemMonitorTests/`:

1. **MockUtilities.swift**: Test helpers and mock objects
2. **SystemMetricsTests.swift**: Core metrics collection and validation
3. **MenuBarControllerTests.swift**: Menu bar integration and UI controller
4. **ViewTests.swift**: SwiftUI component tests
5. **IntegrationTests.swift**: End-to-end system tests

See `Tests/SystemMonitorTests/README.md` for detailed test documentation.

## Version Management

- Version number: `1.0` (defined in `build_app.sh` Info.plist)
- Bundle ID: `com.andrei.systemmonitor`
- Minimum macOS: 14.0
- Swift version: 5.9+

## Common Gotchas

1. **Dual Codebase**: Always update BOTH `Sources/SystemMonitor/` and `SystemMonitor/` directories when changing shared code
2. **Network Stats**: Only monitors en0 interface; won't show VPN or tunnel traffic
3. **Permission Requirements**: App needs Full Disk Access for some system metrics
4. **Menu Bar Icons**: Uses SF Symbols that must be available on macOS 14+
5. **History Arrays**: Automatically truncate at 60 elements, no manual cleanup needed
6. **Disk Display**: Menu bar shows FREE space (not used), popover shows both
