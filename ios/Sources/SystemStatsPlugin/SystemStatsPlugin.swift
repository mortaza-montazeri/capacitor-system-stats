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
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise)
    ]

    @objc func getSystemStats(_ call: CAPPluginCall) {
         var result: [String: Any] = [:]
        
        // CPU Usage (Approximation)
        let usage = ProcessInfo.processInfo.systemUptime
        result["cpuUsage"] = usage
        
        // RAM Usage (Used and Free Memory)        
        result["totalRAM"] = ProcessInfo.processInfo.physicalMemory
        result["availableRAM"] = getFreeMemory()
        
        // Free Disk Space
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let freeSize = systemAttributes[.systemFreeSize] as? NSNumber,
           let totalSize = systemAttributes[.systemSize] as? NSNumber {
            result["availableStorage"] = freeSize.int64Value
            result["totalStorage"] = totalSize.int64Value
        }
        
        call.resolve(result)
    }

    private func getFreeMemory() -> UInt64 {
        let vmStats = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        let freeMemory = vmStats?[.systemFreeSize] as? UInt64 ?? 0
        return freeMemory
    }
}
