import SwiftUI

struct DetailWindow: View {
    @EnvironmentObject var systemMetrics: SystemMetrics
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: Tab = .overview
    
    enum Tab: String, CaseIterable {
        case overview = "Overview"
        case cpu = "CPU"
        case memory = "Memory"
        case network = "Network"
        case disk = "Disk"
        
        var icon: String {
            switch self {
            case .overview: return "chart.line.uptrend.xyaxis"
            case .cpu: return "cpu"
            case .memory: return "memorychip"
            case .network: return "network"
            case .disk: return "externaldrive"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            // Sidebar
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        HStack {
                            Image(systemName: tab.icon)
                                .foregroundColor(selectedTab == tab ? .white : .primary)
                                .frame(width: 20)
                            Text(tab.rawValue)
                                .foregroundColor(selectedTab == tab ? .white : .primary)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            selectedTab == tab ? Color.accentColor : Color.clear
                        )
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                }
                Spacer()
            }
            .frame(width: 150)
            .background(Color(NSColor.controlBackgroundColor))
            
            // Main Content
            Group {
                switch selectedTab {
                case .overview:
                    OverviewView()
                case .cpu:
                    CPUDetailView()
                case .memory:
                    MemoryDetailView()
                case .network:
                    NetworkDetailView()
                case .disk:
                    DiskDetailView()
                }
            }
            .environmentObject(systemMetrics)
        }
        .frame(width: 800, height: 600)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .navigationTitle("System Monitor - \(selectedTab.rawValue)")
    }
}

struct OverviewView: View {
    @EnvironmentObject var systemMetrics: SystemMetrics
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                MetricCard(
                    title: "CPU Usage",
                    value: systemMetrics.formatPercentage(systemMetrics.cpuUsage),
                    icon: "cpu",
                    color: .orange,
                    progress: systemMetrics.cpuUsage / 100.0
                )
                
                MetricCard(
                    title: "Memory Usage",
                    value: systemMetrics.formatPercentage(systemMetrics.memoryUsage),
                    icon: "memorychip",
                    color: .green,
                    progress: systemMetrics.memoryUsage / 100.0,
                    subtitle: "\(systemMetrics.formatBytes(systemMetrics.memoryUsed)) / \(systemMetrics.formatBytes(systemMetrics.memoryTotal))"
                )
                
                MetricCard(
                    title: "Disk Usage",
                    value: systemMetrics.formatPercentage(systemMetrics.diskUsage),
                    icon: "externaldrive",
                    color: .purple,
                    progress: systemMetrics.diskUsage / 100.0,
                    subtitle: "\(systemMetrics.formatBytes(systemMetrics.diskUsed)) / \(systemMetrics.formatBytes(systemMetrics.diskTotal))"
                )
                
                NetworkCard()
            }
            .padding()
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let progress: Double
    let subtitle: String?
    
    init(title: String, value: String, icon: String, color: Color, progress: Double, subtitle: String? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.progress = progress
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(color)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct NetworkCard: View {
    @EnvironmentObject var systemMetrics: SystemMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "network")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Network")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.blue)
                    Text("Download")
                    Spacer()
                    Text(systemMetrics.formatBytesPerSecond(systemMetrics.networkDownload))
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.orange)
                    Text("Upload")
                    Spacer()
                    Text(systemMetrics.formatBytesPerSecond(systemMetrics.networkUpload))
                        .fontWeight(.semibold)
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct CPUDetailView: View {
    @EnvironmentObject var systemMetrics: SystemMetrics
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("CPU Usage: \(systemMetrics.formatPercentage(systemMetrics.cpuUsage))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                ProgressView(value: systemMetrics.cpuUsage / 100.0)
                    .progressViewStyle(.linear)
                    .tint(.orange)
            }
            .padding()
            
            Text("Detailed CPU information would include per-core usage, temperature, and frequency data.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

struct MemoryDetailView: View {
    @EnvironmentObject var systemMetrics: SystemMetrics
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("Memory Usage: \(systemMetrics.formatPercentage(systemMetrics.memoryUsage))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("\(systemMetrics.formatBytes(systemMetrics.memoryUsed)) / \(systemMetrics.formatBytes(systemMetrics.memoryTotal))")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                ProgressView(value: systemMetrics.memoryUsage / 100.0)
                    .progressViewStyle(.linear)
                    .tint(.green)
            }
            .padding()
            
            Text("Detailed memory information would include swap usage, memory pressure, and app-specific usage.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

struct NetworkDetailView: View {
    @EnvironmentObject var systemMetrics: SystemMetrics
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.blue)
                        .font(.largeTitle)
                    Text("Download")
                        .font(.headline)
                    Text(systemMetrics.formatBytesPerSecond(systemMetrics.networkDownload))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.orange)
                        .font(.largeTitle)
                    Text("Upload")
                        .font(.headline)
                    Text(systemMetrics.formatBytesPerSecond(systemMetrics.networkUpload))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            Text("Network charts and interface details would be displayed here.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

struct DiskDetailView: View {
    @EnvironmentObject var systemMetrics: SystemMetrics
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("Disk Usage: \(systemMetrics.formatPercentage(systemMetrics.diskUsage))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("\(systemMetrics.formatBytes(systemMetrics.diskUsed)) / \(systemMetrics.formatBytes(systemMetrics.diskTotal))")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                ProgressView(value: systemMetrics.diskUsage / 100.0)
                    .progressViewStyle(.linear)
                    .tint(.purple)
            }
            .padding()
            
            Text("Detailed disk information would include read/write speeds and per-volume usage.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

