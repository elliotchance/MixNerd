import SwiftUI

struct Track: Identifiable {
  var id = UUID()

  // This is the start time of the track (not the duration).
  var time: String
  var timeIsEstimated: Bool = false

  var artist: String
  var title: String
  var label: String = ""  // e.g. ARMIND

  func String() -> String {
    if label.isEmpty {
      return "[\(formattedTime())] \(artist) - \(title)"
    }
    return "[\(formattedTime())] \(artist) - \(title) [\(label)]"
  }

  func formattedTime() -> String {
    if timeIsEstimated {
      return "~\(time)"
    }
    return time
  }

  func timeSeconds() -> Int {
    let parts = time.split(separator: ":").compactMap { Int($0) }

    if parts.count == 3 {
      // Format: hours:minutes:seconds (e.g., "1:20:45")
      return parts[0] * 3600 + parts[1] * 60 + parts[2]
    } else if parts.count == 2 {
      // Format: minutes:seconds (e.g., "67:00")
      return parts[0] * 60 + parts[1]
    }

    return 0
  }
}
