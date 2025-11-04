import SwiftUI

struct Track: Identifiable {
  let id = UUID()
  let time: String
  let artist: String
  let title: String
}
