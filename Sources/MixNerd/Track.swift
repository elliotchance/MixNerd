import SwiftUI

struct Track: Identifiable {
  var id = UUID()
  var time: String
  var artist: String
  var title: String

  func String() -> String {
    return "[\(time)] \(artist) - \(title)"
  }
}
