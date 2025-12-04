class CueTrack {
  var performer: String
  var title: String
  var time: Duration

  init(performer: String, title: String, time: Duration) {
    self.performer = performer
    self.title = title
    self.time = time
  }

  func content(at index: Int) -> String {
    return [
      "  TRACK \(index < 10 ? "0\(index)" : "\(index)") AUDIO",
      "    PERFORMER \"\(performer)\"",
      "    TITLE \"\(title)\"",
      "    INDEX 01 \(indexTime())",
    ].joined(separator: "\n")
  }

  func indexTime() -> String {
    let seconds = time.components.seconds
    return String(format: "%d:%02d:00", seconds / 60, seconds % 60)
  }
}
