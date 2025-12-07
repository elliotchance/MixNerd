import Foundation

struct Time: CustomStringConvertible {
  var at: TimeInterval
  var isEstimated: Bool

  init() {
    self.at = 0
    self.isEstimated = true
  }

  init(at: TimeInterval) {
    self.at = at
    self.isEstimated = false
  }

  init(estimatedAt: TimeInterval) {
    self.at = estimatedAt
    self.isEstimated = true
  }

  static func isValidTimeString(_ string: String) -> Bool {
    if string.isEmpty {
      return false
    }

    // Check for empty components (leading colon, trailing colon, or double colon)
    if string.hasPrefix(":") || string.hasSuffix(":") || string.contains("::") {
      return false
    }

    let components = string.split(separator: ":")
    guard components.count == 2 || components.count == 3 else {
      return false
    }

    for component in components {
      guard let intValue = Int(component) else {
        return false
      }
      guard intValue >= 0 else {
        return false
      }
    }

    return true
  }

  init(string: String) {
    if !Time.isValidTimeString(string) {
      self.at = 0
      self.isEstimated = true
      return
    }

    let components = string.split(separator: ":")
    if components.count == 3 {
      self.at = Double(components[0])! * 3600 + Double(components[1])! * 60 + Double(components[2])!
    } else if components.count == 2 {
      self.at = Double(components[0])! * 60 + Double(components[1])!
    } else {
      self.at = Double(components[0])!
    }
    self.isEstimated = false
  }

  public var exact: Time {
    return Time(at: at)
  }

  public var description: String {
    let totalSeconds = Int(at)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60

    let formatted: String
    if hours > 0 {
      formatted = String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else {
      formatted = String(format: "%02d:%02d", minutes, seconds)
    }

    if isEstimated {
      return "~\(formatted)"
    }
    return formatted
  }
}
