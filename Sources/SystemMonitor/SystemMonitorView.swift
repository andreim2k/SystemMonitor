import SwiftUI

// MARK: - UI Views
struct LiquidGlassMenuView: View {
    @EnvironmentObject var systemMetrics: SystemMetrics
    @State private var backgroundAnimation = false
    @State private var particleAnimation = false

    var body: some View {
        VStack(spacing: 20) {
            // Header with animated gradient
            headerSection

            // Metrics with glass cards
            metricsSection

            // Action buttons
            actionSection
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 24)
        .frame(width: 360, height: 480)
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

                    Text("macOS • Real-time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    private var metricsSection: some View {
        VStack(spacing: 14) {
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
        VStack(spacing: 12) {
            Button("Quit System Monitor") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(LiquidGlassButtonStyle())
        }
        .padding(.top, 8)
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
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(.white.opacity(0.03))
                    .frame(width: CGFloat.random(in: 3...6))
                    .position(
                        x: CGFloat.random(in: 0...360),
                        y: CGFloat.random(in: 0...480)
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
        .background(liquidGlassBackground(color: color))
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
        .background(liquidGlassBackground(color: .blue))
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

            VStack(spacing: 2) {
                Text(systemMetrics.formatBytes(systemMetrics.diskTotal - systemMetrics.diskUsed))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.purple)

                Text("of \(systemMetrics.formatBytes(systemMetrics.diskTotal))")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .contentTransition(.numericText())

            Text("Storage")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(liquidGlassBackground(color: .purple))
        .onAppear {
            isAnimating = true
        }
    }
}

struct LiquidGlassButtonStyle: ButtonStyle {
    let color: Color

    init(color: Color = .red) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.8), color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

func liquidGlassBackground(color: Color) -> some View {
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
}
