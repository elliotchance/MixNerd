import SwiftUI

struct Track: CustomStringConvertible {
  var id = UUID()

  // This is the start time of the track (not the duration).
  var time: Time

  var artist: String
  var title: String
  var label: String = ""  // e.g. ARMIND

  public var description: String {
    if label.isEmpty {
      return "[\(time)] \(artist) - \(title)"
    }
    return "[\(time)] \(artist) - \(title) [\(label)]"
  }
}
