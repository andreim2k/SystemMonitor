//
//  SystemMonitorApp.swift
//  SystemMonitor
//
//  macOS System Monitor with Menu Bar Display
//  Shows CPU, Memory, Network, and Disk usage with SF Symbols
//  Compatible with macOS 14+
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
                memory: Int(systemMetrics.memoryUsage), 
                network: Int(systemMetrics.networkDownload/(1024*1024)),
                disk: Int(systemMetrics.diskUsage)
            ))
        }
        .menuBarExtraStyle(.window)
    }
    
    // MARK: - Menu Bar Image Creation
    /// Creates a single NSImage with all metrics and SF Symbol icons
    /// This approach bypasses macOS MenuBarExtra limitations
    private func createMenuBarImage(cpu: Int, memory: Int, network: Int, disk: Int) -> NSImage {
        // Calculate total width needed
        let font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white
        ]
        
        let cpuText = "\(cpu)"
        let memText = "\(memory)"
        let netText = "\(network)"
        let diskText = "\(disk)"
        
        let iconSize: CGFloat = 18
        let spacing: CGFloat = 5
        let groupSpacing: CGFloat = 12  // Space between metric groups
        let padding: CGFloat = 8
        
        let totalWidth = padding * 2 + 
                        iconSize + spacing + cpuText.size(withAttributes: textAttributes).width + groupSpacing +
                        iconSize + spacing + memText.size(withAttributes: textAttributes).width + groupSpacing +
                        iconSize + spacing + netText.size(withAttributes: textAttributes).width + groupSpacing +
                        iconSize + spacing + diskText.size(withAttributes: textAttributes).width
        
        let imageSize = NSSize(width: totalWidth, height: 22)
        let image = NSImage(size: imageSize)
        
        image.lockFocus()
        defer { image.unlockFocus() }
        
        // Clear background to transparent
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: imageSize).fill()
        
        var xOffset: CGFloat = padding
        let iconYOffset: CGFloat = 2  // Centered for 18px icons in 22px height
        let textYOffset: CGFloat = 3  // Centered for 13pt text
        
        // CPU - gear icon
        let config = NSImage.SymbolConfiguration(pointSize: iconSize, weight: .regular)
        if let cpuIcon = NSImage(systemSymbolName: "cpu", accessibilityDescription: "CPU")?.withSymbolConfiguration(config) {
            let whiteIcon = cpuIcon.copy() as! NSImage
            whiteIcon.lockFocus()
            NSColor.white.set()
            NSRect(origin: .zero, size: whiteIcon.size).fill(using: .sourceAtop)
            whiteIcon.unlockFocus()
            
            whiteIcon.size = NSSize(width: iconSize, height: iconSize)
            whiteIcon.draw(in: NSRect(x: xOffset, y: iconYOffset, width: iconSize, height: iconSize))
        }
        xOffset += iconSize + spacing
        
        cpuText.draw(at: NSPoint(x: xOffset, y: textYOffset), withAttributes: textAttributes)
        xOffset += cpuText.size(withAttributes: textAttributes).width + groupSpacing
        
        // Memory - chip icon
        if let memIcon = NSImage(systemSymbolName: "memorychip", accessibilityDescription: "Memory")?.withSymbolConfiguration(config) {
            let whiteIcon = memIcon.copy() as! NSImage
            whiteIcon.lockFocus()
            NSColor.white.set()
            NSRect(origin: .zero, size: whiteIcon.size).fill(using: .sourceAtop)
            whiteIcon.unlockFocus()
            
            whiteIcon.size = NSSize(width: iconSize, height: iconSize)
            whiteIcon.draw(in: NSRect(x: xOffset, y: iconYOffset, width: iconSize, height: iconSize))
        }
        xOffset += iconSize + spacing
        
        memText.draw(at: NSPoint(x: xOffset, y: textYOffset), withAttributes: textAttributes)
        xOffset += memText.size(withAttributes: textAttributes).width + groupSpacing
        
        // Network - wifi icon
        if let netIcon = NSImage(systemSymbolName: "wifi", accessibilityDescription: "Network")?.withSymbolConfiguration(config) {
            let whiteIcon = netIcon.copy() as! NSImage
            whiteIcon.lockFocus()
            NSColor.white.set()
            NSRect(origin: .zero, size: whiteIcon.size).fill(using: .sourceAtop)
            whiteIcon.unlockFocus()
            
            whiteIcon.size = NSSize(width: iconSize, height: iconSize)
            whiteIcon.draw(in: NSRect(x: xOffset, y: iconYOffset, width: iconSize, height: iconSize))
        }
        xOffset += iconSize + spacing
        
        netText.draw(at: NSPoint(x: xOffset, y: textYOffset), withAttributes: textAttributes)
        xOffset += netText.size(withAttributes: textAttributes).width + groupSpacing
        
        // Disk - external drive icon
        if let diskIcon = NSImage(systemSymbolName: "externaldrive", accessibilityDescription: "Disk")?.withSymbolConfiguration(config) {
            let whiteIcon = diskIcon.copy() as! NSImage
            whiteIcon.lockFocus()
            NSColor.white.set()
            NSRect(origin: .zero, size: whiteIcon.size).fill(using: .sourceAtop)
            whiteIcon.unlockFocus()
            
            whiteIcon.size = NSSize(width: iconSize, height: iconSize)
            whiteIcon.draw(in: NSRect(x: xOffset, y: iconYOffset, width: iconSize, height: iconSize))
        }
        xOffset += iconSize + spacing
        
        diskText.draw(at: NSPoint(x: xOffset, y: textYOffset), withAttributes: textAttributes)
        
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
                    
                    Text("macOS 14+ • Real-time")
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
                LiquidGlassMetricCard(
                    title: "Network",
                    value: "\(Int(systemMetrics.networkDownload/(1024*1024)))M",
                    color: .blue,
                    icon: "wifi"
                )
                
                LiquidGlassMetricCard(
                    title: "Disk",
                    value: systemMetrics.formatPercentage(systemMetrics.diskUsage),
                    color: .purple,
                    icon: "externaldrive"
                )
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
