import ID3TagEditor

public class Date: CustomStringConvertible {
  var year: Int
  var month: Int
  var day: Int

  init(year: Int, month: Int, day: Int) {
    self.year = year
    self.month = month
    self.day = day

    if year < 1900 || year > 2100 {
      self.year = 0
      self.month = 0
      self.day = 0
    }
  }

  convenience init() {
    self.init(year: 0, month: 0, day: 0)
  }

  convenience init(fromString dateString: String) {
    let components = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
      .split(separator: "-")

    if components.count == 3 {
      if let year = Int(components[0]),
        let month = Int(components[1]),
        let day = Int(components[2])
      {
        self.init(year: year, month: month, day: day)
      } else {
        self.init(year: 0, month: 0, day: 0)
      }
    } else if components.count == 1 {
      if let year = Int(components[0]) {
        self.init(year: year, month: 0, day: 0)
      } else {
        self.init(year: 0, month: 0, day: 0)
      }
    } else {
      self.init(year: 0, month: 0, day: 0)
    }
  }

  convenience init(fromID3TagContentReader tagContentReader: ID3TagContentReader) {
    let date = tagContentReader.recordingDateTime()
    self.init(year: date?.year ?? 0, month: date?.month ?? 0, day: date?.day ?? 0)
  }

  func toID3FrameRecordingDateTime() -> ID3FrameRecordingDateTime {
    return ID3FrameRecordingDateTime(
      recordingDateTime: RecordingDateTime(
        date: RecordingDate(day: day, month: month, year: year), time: nil))
  }

  public var description: String {
    if year == 0 {
      return ""
    }
    if month == 0 {
      return "\(year)"
    }
    return "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
  }
}
