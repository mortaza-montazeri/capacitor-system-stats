import Foundation

@objc public class SystemStats: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
