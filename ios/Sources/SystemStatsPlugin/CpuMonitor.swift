import Foundation

class CpuMonitor {
    private var lastCpuTimeMs: UInt64 = 0
    private var lastWallTimeMs: UInt64 = 0
    private let numCores = ProcessInfo.processInfo.processorCount

    init() {
        lastCpuTimeMs = CpuMonitor.getTotalCpuTime()
        lastWallTimeMs = CpuMonitor.getWallTime()
    }

    func getAppCpuUsage() -> Float {
        let currentCpuTime = CpuMonitor.getTotalCpuTime()
        let currentWallTime = CpuMonitor.getWallTime()

        let cpuDelta = currentCpuTime > lastCpuTimeMs ? currentCpuTime - lastCpuTimeMs : 0
        let wallDelta = currentWallTime > lastWallTimeMs ? currentWallTime - lastWallTimeMs : 0

        lastCpuTimeMs = currentCpuTime
        lastWallTimeMs = currentWallTime

        guard wallDelta > 0 else { return 0 }

        let usage = (Float(cpuDelta) / Float(wallDelta)) * 100 / Float(numCores)
        return usage
    }

    private static func getWallTime() -> UInt64 {
        return UInt64(ProcessInfo.processInfo.systemUptime * 1000)
    }

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

        // Free memory
        vm_deallocate(mach_task_self_,
                      vm_address_t(UInt(bitPattern: threadsList)),
                      vm_size_t(threadCount) * UInt64(MemoryLayout<thread_t>.stride))

        return UInt64(totalTimeSeconds * 1000) // milliseconds
    }
}
