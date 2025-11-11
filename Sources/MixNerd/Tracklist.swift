import AppKit

struct Tracklist: @unchecked Sendable {
  var artwork: NSImage? = nil
  var artworkURL: String = ""

  var date: String = ""
  var artist: String = ""
  var title: String = ""
  var source: String = ""
  var genre: String = ""
  var tracks: [Track] = []
  var editable: Bool = false

  // e.g. 1001.tl/1u7zqrvk
  var shortLink: String = ""
}
