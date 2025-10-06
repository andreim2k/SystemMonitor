import Foundation
import Combine
@testable import SystemMonitor

// MARK: - Mock System Metrics
class MockSystemMetrics: ObservableObject {
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
    
    // Mock data for testing
    func setMockData(
        cpu: Double = 25.0,
        memory: Double = 60.0,
        memoryUsed: Int64 = 8 * 1024 * 1024 * 1024, // 8GB
        memoryTotal: Int64 = 16 * 1024 * 1024 * 1024, // 16GB
        networkUpload: Double = 5.5,
        networkDownload: Double = 12.3,
        diskUsage: Double = 45.0,
        diskUsed: Int64 = 500 * 1024 * 1024 * 1024, // 500GB
        diskTotal: Int64 = 1000 * 1024 * 1024 * 1024 // 1TB
    ) {
        self.cpuUsage = cpu
        self.memoryUsage = memory
        self.memoryUsed = memoryUsed
        self.memoryTotal = memoryTotal
        self.networkUpload = networkUpload
        self.networkDownload = networkDownload
        self.diskUsage = diskUsage
        self.diskUsed = diskUsed
        self.diskTotal = diskTotal
    }
    
    // Mock formatting methods
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

// MARK: - Mock Network Stats
struct MockNetworkStats {
    let bytesIn: UInt64
    let bytesOut: UInt64
    
    static let sample = MockNetworkStats(bytesIn: 1000000, bytesOut: 500000)
    static let highTraffic = MockNetworkStats(bytesIn: 10000000, bytesOut: 5000000)
    static let noTraffic = MockNetworkStats(bytesIn: 0, bytesOut: 0)
}

// MARK: - Test Helpers
class TestHelpers {
    static func waitForAsyncOperation(timeout: TimeInterval = 1.0) async {
        try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
    }
    
    static func createMockSystemMetrics() -> MockSystemMetrics {
        let metrics = MockSystemMetrics()
        metrics.setMockData()
        return metrics
    }
    
    static func createHighLoadSystemMetrics() -> MockSystemMetrics {
        let metrics = MockSystemMetrics()
        metrics.setMockData(
            cpu: 85.0,
            memory: 90.0,
            networkUpload: 50.0,
            networkDownload: 100.0,
            diskUsage: 95.0
        )
        return metrics
    }
    
    static func createLowLoadSystemMetrics() -> MockSystemMetrics {
        let metrics = MockSystemMetrics()
        metrics.setMockData(
            cpu: 5.0,
            memory: 20.0,
            networkUpload: 0.1,
            networkDownload: 0.5,
            diskUsage: 10.0
        )
        return metrics
    }
}

// MARK: - Test Expectations
extension XCTestCase {
    func expectAsync<T>(
        _ expression: @autoclosure () async throws -> T,
        timeout: TimeInterval = 1.0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                return try await expression()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw TestError.timeout
            }
            
            guard let result = try await group.next() else {
                throw TestError.timeout
            }
            
            group.cancelAll()
            return result
        }
    }
}

// MARK: - Test Errors
enum TestError: Error {
    case timeout
    case mockDataNotSet
    case invalidMetricValue
}

// MARK: - Test Constants
struct TestConstants {
    static let defaultTimeout: TimeInterval = 1.0
    static let longTimeout: TimeInterval = 5.0
    static let shortTimeout: TimeInterval = 0.1
    
    // Mock system values
    static let mockCPUUsage: Double = 25.0
    static let mockMemoryUsage: Double = 60.0
    static let mockNetworkUpload: Double = 5.5
    static let mockNetworkDownload: Double = 12.3
    static let mockDiskUsage: Double = 45.0
    
    // Memory values in bytes
    static let mockMemoryUsed: Int64 = 8 * 1024 * 1024 * 1024 // 8GB
    static let mockMemoryTotal: Int64 = 16 * 1024 * 1024 * 1024 // 16GB
    static let mockDiskUsed: Int64 = 500 * 1024 * 1024 * 1024 // 500GB
    static let mockDiskTotal: Int64 = 1000 * 1024 * 1024 * 1024 // 1TB
}
