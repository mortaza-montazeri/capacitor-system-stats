import Foundation

class CpuMonitor {
    private var lastAppTimeMs: UInt64 = 0
    private var lastTotalTimeMs: UInt64 = 0
    private let numCores: Int = ProcessInfo.processInfo.processorCount

    init() {
        let (app, total) = CpuMonitor.sampleTimes()
        lastAppTimeMs = app
        lastTotalTimeMs = total
    }

    func getAppCpuUsage() -> Float {
        let (currentAppTimeMs, currentTotalTimeMs) = CpuMonitor.sampleTimes()

        let appDelta = currentAppTimeMs > lastAppTimeMs ? currentAppTimeMs - lastAppTimeMs : 0
        let totalDelta = currentTotalTimeMs > lastTotalTimeMs ? currentTotalTimeMs - lastTotalTimeMs : 0

        lastAppTimeMs = currentAppTimeMs
        lastTotalTimeMs = currentTotalTimeMs

        guard totalDelta > 0 else { return 0 }

        let rawUsage = Float(appDelta) / Float(totalDelta) * 100
        return rawUsage / Float(numCores)
    }

    /// Synchronously samples app uptime and total CPU time (in milliseconds)
    private static func sampleTimes() -> (appTimeMs: UInt64, totalCpuTimeMs: UInt64) {
        let appTimeMs = UInt64(ProcessInfo.processInfo.systemUptime * 1000)
        let totalCpuTimeMs = getTotalCpuTime()
        return (appTimeMs, totalCpuTimeMs)
    }

    /// Returns total CPU time (all threads of current process) in milliseconds
    private static func getTotalCpuTime() -> UInt64 {
        var threadsList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t(0)

        let result = task_threads(mach_task_self_, &threadsList, &threadCount)
        guard result == KERN_SUCCESS, let threads = threadsList else {
            return 0
        }

        var totalTimeSeconds: TimeInterval = 0

        for i in 0..<Int(threadCount) {
            var threadInfoData = thread_basic_info()
            var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)

            let kr = withUnsafeMutablePointer(to: &threadInfoData) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(threadInfoCount)) {
                    thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                }
            }

            if kr == KERN_SUCCESS && (threadInfoData.flags & TH_FLAGS_IDLE) == 0 {
                let userTime = TimeInterval(threadInfoData.user_time.seconds) + TimeInterval(threadInfoData.user_time.microseconds) / 1_000_000
                let systemTime = TimeInterval(threadInfoData.system_time.seconds) + TimeInterval(threadInfoData.system_time.microseconds) / 1_000_000
                totalTimeSeconds += userTime + systemTime
            }
        }

        // Clean up
        vm_deallocate(mach_task_self_,
                      vm_address_t(UInt(bitPattern: threadsList)),
                      vm_size_t(threadCount) * UInt64(MemoryLayout<thread_t>.stride))

        return UInt64(totalTimeSeconds * 1000)
    }
}
