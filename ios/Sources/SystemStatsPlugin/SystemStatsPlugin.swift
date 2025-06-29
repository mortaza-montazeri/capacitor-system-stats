import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(SystemStatsPlugin)
public class SystemStatsPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "SystemStatsPlugin"
    public let jsName = "SystemStats"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "getSystemStats", returnType: CAPPluginReturnPromise)
    ]

    @objc func getSystemStats(_ call: CAPPluginCall) {
         var result: [String: Any] = [:]
        
        // CPU Usage (Approximation)
        let usage = ProcessInfo.processInfo.systemUptime
        result["cpuUsage"] = usage
        
        // RAM Usage (Used and Free Memory)        
        result["totalRAM"] = ProcessInfo.processInfo.physicalMemory
        result["availableRAM"] = getFreeRAM()
        
        // Free Disk Space
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let freeSize = systemAttributes[.systemFreeSize] as? NSNumber,
           let totalSize = systemAttributes[.systemSize] as? NSNumber {
            result["availableStorage"] = freeSize.int64Value
            result["totalStorage"] = totalSize.int64Value
        }
        
        call.resolve(result)
    }

    private func getFreeRAM() -> UInt64 {
       var size = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)
        var vmStats = vm_statistics64()

        let hostPort: host_t = mach_host_self()
        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &size)
            }
        }

        if result != KERN_SUCCESS {
            return 0
        }

        // Page size in bytes
        let pageSize = UInt64(vm_kernel_page_size)

        // Free memory in bytes = free_count * page size
        let freeMemory = UInt64(vmStats.free_count) * pageSize
        return freeMemory
    }
}
