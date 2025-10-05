//
//  SystemMonitorApp.swift
//  SystemMonitor
//
//  macOS System Monitor with Menu Bar Display
//  Shows CPU, Memory, Network, and Disk usage with SF Symbols
//  Compatible with macOS 26+
//

import SwiftUI
import Foundation
import IOKit
import Combine

// MARK: - Main App
@main
struct SystemMonitorApp: App {
    @StateObject private var systemMetrics = SystemMetrics()
    
    var body: some Scene {
        MenuBarExtra {
            LiquidGlassMenuView()
                .environmentObject(systemMetrics)
        } label: {
            Image(nsImage: createMenuBarImage(
                cpu: Int(systemMetrics.cpuUsage),
                networkUp: Int(systemMetrics.networkUpload),
                networkDown: Int(systemMetrics.networkDownload),
                diskFreeGB: Int((systemMetrics.diskTotal - systemMetrics.diskUsed) / (1024*1024*1024))
            ))
        }
        .menuBarExtraStyle(.window)
    }
    
    // MARK: - Menu Bar Image Creation
    /// Creates a single NSImage with all metrics and SF Symbol icons
    /// This approach bypasses macOS 26 MenuBarExtra limitations
    private func createMenuBarImage(cpu: Int, networkUp: Int, networkDown: Int, diskFreeGB: Int) -> NSImage {
        // Calculate total width needed with bigger, readable font
        let font = NSFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        // Use white color for menu bar visibility (menu bar apps typically use white)
        let textColor = NSColor.white
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        
        let cpuText = "\(cpu)%"
        let netUpText = "\(networkUp)"
        let netDownText = "\(networkDown)"
        let diskFreeText = "\(diskFreeGB)GB"
        
        let iconSize: CGFloat = 20
        let spacing: CGFloat = 5
        let groupSpacing: CGFloat = 12  // Space between metric groups
        let padding: CGFloat = 10
        
        let separatorText = "/"
        
        // Calculate width for each metric group using natural icon sizes
        let naturalIconWidth: CGFloat = 16  // Natural width of 16pt SF Symbols
        let cpuIconTextSpacing: CGFloat = 5  // Space between CPU icon and percentage
        let diskIconTextSpacing: CGFloat = 7  // Space between disk icon and GB text (extra space)
        let cpuWidth = naturalIconWidth + cpuIconTextSpacing + cpuText.size(withAttributes: textAttributes).width
        let netText = "↑\(netUpText)/↓\(netDownText)"
        let netWidth = naturalIconWidth + spacing + netText.size(withAttributes: textAttributes).width
        let diskWidth = naturalIconWidth + diskIconTextSpacing + diskFreeText.size(withAttributes: textAttributes).width
        
        let totalWidth = cpuWidth + groupSpacing + netWidth + groupSpacing + diskWidth  // No padding at all
        
        let imageSize = NSSize(width: totalWidth, height: 24)  // Slightly taller for bigger content
        let image = NSImage(size: imageSize)
        
        image.lockFocus()
        defer { image.unlockFocus() }
        
        // Clear background to transparent
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: imageSize).fill()
        
        var xOffset: CGFloat = 0  // Start at the very beginning
        let iconYOffset: CGFloat = 2  // Centered for 20px icons in 24px height
        let textYOffset: CGFloat = 6   // Centered text for 12pt font
        
        // CPU - processor icon that adapts to system theme
        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        if let cpuIcon = NSImage(systemSymbolName: "cpu.fill", accessibilityDescription: "CPU")?.withSymbolConfiguration(config) {
            let themedIcon = cpuIcon.copy() as! NSImage
            themedIcon.lockFocus()
            textColor.set()  // Use same color as text for theme consistency
            NSRect(origin: .zero, size: themedIcon.size).fill(using: .sourceAtop)
            themedIcon.unlockFocus()
            
            // Draw icon at natural size, centered vertically
            let iconRect = NSRect(x: xOffset, y: (imageSize.height - themedIcon.size.height) / 2, width: themedIcon.size.width, height: themedIcon.size.height)
            themedIcon.draw(in: iconRect)
        }
        
        // Add CPU text centered with the natural-sized icon
        xOffset += naturalIconWidth + cpuIconTextSpacing
        let cpuTextHeight = cpuText.size(withAttributes: textAttributes).height
        let cpuTextY = (imageSize.height - cpuTextHeight) / 2
        cpuText.draw(at: NSPoint(x: xOffset, y: cpuTextY), withAttributes: textAttributes)
        xOffset += cpuText.size(withAttributes: textAttributes).width + groupSpacing
        
        // Memory section removed - no display in menu bar
        
        // Network - activity icon that adapts to system theme
        if let netIcon = NSImage(systemSymbolName: "arrow.up.arrow.down.circle.fill", accessibilityDescription: "Network")?.withSymbolConfiguration(config) {
            let themedIcon = netIcon.copy() as! NSImage
            themedIcon.lockFocus()
            textColor.set()  // Use same color as text for theme consistency
            NSRect(origin: .zero, size: themedIcon.size).fill(using: .sourceAtop)
            themedIcon.unlockFocus()
            
            // Draw icon at natural size, centered vertically
            let iconRect = NSRect(x: xOffset, y: (imageSize.height - themedIcon.size.height) / 2, width: themedIcon.size.width, height: themedIcon.size.height)
            themedIcon.draw(in: iconRect)
        }
        xOffset += naturalIconWidth + spacing
        
        // Draw upload/download centered with icon
        let netTextHeight = netText.size(withAttributes: textAttributes).height
        let netTextY = (imageSize.height - netTextHeight) / 2
        netText.draw(at: NSPoint(x: xOffset, y: netTextY), withAttributes: textAttributes)
        xOffset += netText.size(withAttributes: textAttributes).width + groupSpacing
        
        // Disk - storage icon that adapts to system theme
        if let diskIcon = NSImage(systemSymbolName: "internaldrive.fill", accessibilityDescription: "Disk")?.withSymbolConfiguration(config) {
            let themedIcon = diskIcon.copy() as! NSImage
            themedIcon.lockFocus()
            textColor.set()  // Use same color as text for theme consistency
            NSRect(origin: .zero, size: themedIcon.size).fill(using: .sourceAtop)
            themedIcon.unlockFocus()
            
            // Draw icon at natural size, centered vertically
            let iconRect = NSRect(x: xOffset, y: (imageSize.height - themedIcon.size.height) / 2, width: themedIcon.size.width, height: themedIcon.size.height)
            themedIcon.draw(in: iconRect)
        }
        xOffset += naturalIconWidth + diskIconTextSpacing
        
        // Draw disk free space centered with icon
        let diskTextHeight = diskFreeText.size(withAttributes: textAttributes).height
        let diskTextY = (imageSize.height - diskTextHeight) / 2
        diskFreeText.draw(at: NSPoint(x: xOffset, y: diskTextY), withAttributes: textAttributes)
        
        // Set as template image for proper menu bar rendering
        image.isTemplate = true
        return image
    }
}

// MARK: - UI Views
struct LiquidGlassMenuView: View {
    @EnvironmentObject var systemMetrics: SystemMetrics
    @State private var backgroundAnimation = false
    @State private var particleAnimation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with animated gradient
            headerSection
            
            // Metrics with glass cards
            metricsSection
            
            // Action buttons
            actionSection
        }
        .padding(24)
        .frame(width: 360, height: 420)
        .background(
            ZStack {
                // Animated background gradient
                backgroundGradient
                
                // Floating particles
                particleOverlay
                
                // Glass overlay
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            }
        )
        .onAppear {
            backgroundAnimation = true
            particleAnimation = true
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.blue.opacity(0.6), .purple.opacity(0.4)],
                                center: .center,
                                startRadius: 5,
                                endRadius: 20
                            )
                        )
                        .frame(width: 32, height: 32)
                        .scaleEffect(backgroundAnimation ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(), value: backgroundAnimation)
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("System Monitor")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("macOS 26 • Real-time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
                .background(.white.opacity(0.2))
        }
    }
    
    private var metricsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                LiquidGlassMetricCard(
                    title: "CPU",
                    value: systemMetrics.formatPercentage(systemMetrics.cpuUsage),
                    color: .orange,
                    icon: "cpu"
                )
                
                LiquidGlassMetricCard(
                    title: "Memory",
                    value: systemMetrics.formatPercentage(systemMetrics.memoryUsage),
                    color: .green,
                    icon: "memorychip"
                )
            }
            
            HStack(spacing: 12) {
                LiquidGlassNetworkCard()
                
                LiquidGlassDiskCard()
            }
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 16) {
            Divider()
                .background(.white.opacity(0.2))
            
            Button("Quit System Monitor") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(LiquidGlassButtonStyle())
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.1),
                Color.purple.opacity(0.08),
                Color.pink.opacity(0.05),
                Color.blue.opacity(0.1)
            ],
            startPoint: backgroundAnimation ? .topLeading : .bottomTrailing,
            endPoint: backgroundAnimation ? .bottomTrailing : .topLeading
        )
        .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: backgroundAnimation)
    }
    
    private var particleOverlay: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: CGFloat.random(in: 4...8))
                    .position(
                        x: CGFloat.random(in: 0...360),
                        y: CGFloat.random(in: 0...420)
                    )
                    .animation(
                        .linear(duration: Double.random(in: 4...8))
                        .repeatForever(autoreverses: true),
                        value: particleAnimation
                    )
            }
        }
        .allowsHitTesting(false)
    }
}

struct LiquidGlassMetricCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(color)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(), value: isAnimating)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .onAppear {
            isAnimating = true
        }
    }
}

struct LiquidGlassNetworkCard: View {
    @EnvironmentObject var systemMetrics: SystemMetrics
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "network.badge.shield.half.filled")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.blue)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(), value: isAnimating)
            
            HStack(spacing: 4) {
                Text("↑\(String(format: "%.1f", systemMetrics.networkUpload))MB/s")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
                
                Text("↓\(String(format: "%.1f", systemMetrics.networkDownload))MB/s")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
            }
            .contentTransition(.numericText())
            
            Text("Network")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .orange.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .blue.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .onAppear {
            isAnimating = true
        }
    }
}

struct LiquidGlassDiskCard: View {
    @EnvironmentObject var systemMetrics: SystemMetrics
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "externaldrive.fill.badge.plus")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.purple)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(), value: isAnimating)
            
            Text(systemMetrics.formatBytes(systemMetrics.diskTotal - systemMetrics.diskUsed))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.purple)
            .contentTransition(.numericText())
            
            Text("Storage")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.purple.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .purple.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .onAppear {
            isAnimating = true
        }
    }
}

struct LiquidGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.red.opacity(0.8), .red.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
