import Foundation

class CpuMonitor {
    private var lastAppCpuTime: TimeInterval = ProcessInfo.processInfo.systemUptime
    private var lastTotalCpuTime: TimeInterval = CpuMonitor.getTotalCpuTime()
    private let numCores: Int = ProcessInfo.processInfo.processorCount

    func getAppCpuUsage() -> Float {
        let currentAppTime = ProcessInfo.processInfo.systemUptime
        let currentTotalTime = CpuMonitor.getTotalCpuTime()

        let appDelta = currentAppTime - lastAppCpuTime
        let totalDelta = currentTotalTime - lastTotalCpuTime

        lastAppCpuTime = currentAppTime
        lastTotalCpuTime = currentTotalTime

        guard totalDelta > 0 else { return 0 }

        // Similar to Android: appDelta / totalDelta * 100 / numCores
        let rawUsage = Float(appDelta / totalDelta) * 100.0
        return rawUsage / Float(numCores)
    }

    /// Returns the system's total CPU time (sum of all core activities) in seconds.
    private static func getTotalCpuTime() -> TimeInterval {
        var threadsList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t(0)

        let result = task_threads(mach_task_self_, &threadsList, &threadCount)
        guard result == KERN_SUCCESS, let threads = threadsList else {
            return 0
        }

        var totalTime: TimeInterval = 0

        for i in 0..<Int(threadCount) {
            var threadInfoData = thread_basic_info()
            var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)

            let kr = withUnsafeMutablePointer(to: &threadInfoData) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(threadInfoCount)) {
                    thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                }
            }

            if kr == KERN_SUCCESS {
                let userTime = TimeInterval(threadInfoData.user_time.seconds) + TimeInterval(threadInfoData.user_time.microseconds) / 1_000_000
                let systemTime = TimeInterval(threadInfoData.system_time.seconds) + TimeInterval(threadInfoData.system_time.microseconds) / 1_000_000
                totalTime += userTime + systemTime
            }
        }

        // Free the thread list
        vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threads)), vm_size_t(threadCount) * vm_size_t(MemoryLayout<thread_t>.stride))

        return totalTime
    }
}
