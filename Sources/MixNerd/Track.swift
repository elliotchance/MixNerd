import SwiftUI

struct Track: Identifiable {
  var id = UUID()
  var time: String
  var artist: String
  var title: String
  var label: String = ""  // e.g. ARMIND

  func String() -> String {
    if label.isEmpty {
      return "[\(time)] \(artist) - \(title)"
    }
    return "[\(time)] \(artist) - \(title) [\(label)]"
  }
}
