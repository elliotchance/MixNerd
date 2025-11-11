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
}
