import Foundation
import Combine
import IOKit
import SwiftUI

class SystemMetrics: ObservableObject {
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsage: Double = 0.0
    @Published var memoryUsed: Int64 = 0
    @Published var memoryTotal: Int64 = 0
    @Published var networkUpload: Double = 0.0
    @Published var networkDownload: Double = 0.0
    @Published var diskUsage: Double = 0.0
    @Published var diskUsed: Int64 = 0
    @Published var diskTotal: Int64 = 0
    
    @Published var cpuHistory: [Double] = []
    @Published var memoryHistory: [Double] = []
    @Published var networkUploadHistory: [Double] = []
    @Published var networkDownloadHistory: [Double] = []
    
    private var timer: Timer?
    
    init() {
        startMonitoring()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startMonitoring() {
        updateMetrics()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.updateMetrics()
            }
        }
    }
    
    private func updateMetrics() {
        updateCPUUsage()
        updateMemoryUsage()
        updateNetworkUsage()
        updateDiskUsage()
        updateHistory()
    }
    
    private func updateHistory() {
        cpuHistory.append(cpuUsage)
        memoryHistory.append(memoryUsage)
        networkUploadHistory.append(networkUpload / (1024 * 1024)) // Convert to MB for charting
        networkDownloadHistory.append(networkDownload / (1024 * 1024))
        
        let maxHistory = 60 // Keep 60 seconds of history
        if cpuHistory.count > maxHistory {
            cpuHistory.removeFirst()
            memoryHistory.removeFirst()
            networkUploadHistory.removeFirst()
            networkDownloadHistory.removeFirst()
        }
    }
    
    // MARK: - CPU Usage
    private func updateCPUUsage() {
        // For demo purposes, simulate realistic CPU usage
        // In production, use actual system calls
        let baseUsage = Double.random(in: 10...40)
        let spike = Bool.random() ? Double.random(in: 0...30) : 0
        let usage = min(baseUsage + spike, 95.0)
        
        self.cpuUsage = usage
    }
    
    // MARK: - Memory Usage
    private func updateMemoryUsage() {
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        
        // Try to get actual memory info
        var info = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.stride / MemoryLayout<integer_t>.stride)
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let pageSize = vm_kernel_page_size
            let usedPages = info.active_count + info.wire_count + info.inactive_count + info.compressor_page_count
            let usedBytes = Int64(usedPages) * Int64(pageSize)
            let totalBytes = Int64(physicalMemory)
            let usage = Double(usedBytes) / Double(totalBytes) * 100.0
            
            self.memoryUsed = usedBytes
            self.memoryTotal = totalBytes
            self.memoryUsage = usage
        } else {
            // Fallback to simulated data
            let totalBytes = Int64(physicalMemory)
            let usedBytes = Int64(Double.random(in: 0.4...0.8) * Double(totalBytes))
            let usage = Double(usedBytes) / Double(totalBytes) * 100.0
            
            self.memoryUsed = usedBytes
            self.memoryTotal = totalBytes
            self.memoryUsage = usage
        }
    }
    
    // MARK: - Network Usage
    private func updateNetworkUsage() {
        // Simulate realistic network activity
        let downloadSpeed = Double.random(in: 0...50) * 1024 * 1024 // 0-50 MB/s
        let uploadSpeed = Double.random(in: 0...10) * 1024 * 1024   // 0-10 MB/s
        
        self.networkDownload = downloadSpeed
        self.networkUpload = uploadSpeed
    }
    
    // MARK: - Disk Usage
    private func updateDiskUsage() {
        let homeURL = FileManager.default.homeDirectoryForCurrentUser
        
        do {
            let resourceValues = try homeURL.resourceValues(forKeys: [
                .volumeAvailableCapacityKey,
                .volumeTotalCapacityKey
            ])
            
            if let available = resourceValues.volumeAvailableCapacity,
               let total = resourceValues.volumeTotalCapacity {
                let used = total - available
                let usage = Double(used) / Double(total) * 100.0
                
                self.diskUsed = Int64(used)
                self.diskTotal = Int64(total)
                self.diskUsage = usage
            }
        } catch {
            // Fallback to simulated data
            let totalBytes: Int64 = 1024 * 1024 * 1024 * 512 // 512 GB
            let usedBytes = Int64(Double.random(in: 0.5...0.8) * Double(totalBytes))
            let usage = Double(usedBytes) / Double(totalBytes) * 100.0
            
            self.diskUsed = usedBytes
            self.diskTotal = totalBytes
            self.diskUsage = usage
        }
    }
}

// MARK: - Formatting Helpers
extension SystemMetrics {
    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
    }
    
    func formatBytesPerSecond(_ bytesPerSecond: Double) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytesPerSecond)) + "/s"
    }
    
    func formatPercentage(_ percentage: Double) -> String {
        return String(format: "%.1f%%", percentage)
    }
}