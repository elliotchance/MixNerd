import AppKit

struct Tracklist: @unchecked Sendable {
  var artwork: Artwork = Artwork()
  var date: Date = Date()
  var artist: String = ""
  var title: String = ""
  var source: String = ""
  var genre: String = ""
  var tracks: [Track] = []

  // e.g. https://1001.tl/1u7zqrvk
  var shortLink: URL?

  var duration: TimeInterval = 2 * 3600  // 2 hours

  /// Returns a copy of the current `tracks` where empty time fields are back-filled by
  /// interpolating between the known track times and `duration`.
  /// - Returns: The tracks with missing `time` values populated.
  func calculateMissingTrackTimes() -> [Track] {
    guard !tracks.isEmpty else {
      return tracks
    }

    var updatedTracks = tracks

    let knownTimes = tracks.enumerated().compactMap { index, track -> (Int, TimeInterval)? in
      guard let seconds = Self.parseTime(track.time) else {
        return nil
      }
      return (index, seconds)
    }

    if knownTimes.isEmpty {
      guard duration > 0 else {
        return updatedTracks
      }

      let step =
        tracks.count > 1
        ? duration / Double(tracks.count - 1)
        : 0.0

      for index in updatedTracks.indices where updatedTracks[index].time.isEmpty {
        let newTime = step.isFinite ? Double(index) * step : 0.0
        updatedTracks[index].time = Self.formatTime(newTime)
        updatedTracks[index].timeIsEstimated = true
      }

      return updatedTracks
    }

    // Leading gap (before the first known time)
    if let firstKnown = knownTimes.first, firstKnown.0 > 0 {
      let span = max(firstKnown.1, 0)
      let gapCount = firstKnown.0
      let initialStep =
        gapCount > 0
        ? (gapCount > 1 ? span / Double(gapCount) : span)
        : 0.0
      let step = initialStep > 0 ? initialStep : 60.0

      for offset in 0..<gapCount {
        let index = offset
        guard updatedTracks[index].time.isEmpty else {
          continue
        }

        let newTime = Double(offset) * step
        updatedTracks[index].time = Self.formatTime(newTime)
        updatedTracks[index].timeIsEstimated = true
      }
    }

    // Gaps between known times
    for (left, right) in zip(knownTimes, knownTimes.dropFirst()) {
      let gapCount = right.0 - left.0 - 1
      guard gapCount > 0 else {
        continue
      }

      let span = right.1 - left.1
      let step =
        span > 0
        ? span / Double(gapCount + 1)
        : 60.0

      for offset in 1...gapCount {
        let index = left.0 + offset
        guard updatedTracks[index].time.isEmpty else {
          continue
        }

        let newTime = left.1 + step * Double(offset)
        updatedTracks[index].time = Self.formatTime(newTime)
        updatedTracks[index].timeIsEstimated = true
      }
    }

    // Trailing gap (after the last known time)
    if let lastKnown = knownTimes.last {
      let remaining = updatedTracks.count - lastKnown.0 - 1
      if remaining > 0 {
        let span = max(duration - lastKnown.1, 0)
        let step =
          span > 0
          ? span / Double(remaining + 1)
          : 60.0

        for offset in 1...remaining {
          let index = lastKnown.0 + offset
          guard updatedTracks[index].time.isEmpty else {
            continue
          }

          let newTime = lastKnown.1 + step * Double(offset)
          updatedTracks[index].time = Self.formatTime(newTime)
          updatedTracks[index].timeIsEstimated = true
        }
      }
    }

    return updatedTracks
  }

  /// Returns a new `Tracklist` where missing track times have been calculated.
  func withCalculatedMissingTrackTimes() -> Tracklist {
    var updated = self
    updated.tracks = calculateMissingTrackTimes()
    return updated
  }

  private static func parseTime(_ time: String) -> TimeInterval? {
    guard !time.isEmpty else {
      return nil
    }

    let parts = time.split(separator: ":").map { String($0) }
    guard parts.count == 2 || parts.count == 3 else {
      return nil
    }

    let numbers = parts.compactMap { Int($0) }
    guard numbers.count == parts.count else {
      return nil
    }

    if numbers.count == 3 {
      return TimeInterval(numbers[0] * 3600 + numbers[1] * 60 + numbers[2])
    }

    return TimeInterval(numbers[0] * 60 + numbers[1])
  }

  private static func formatTime(_ time: TimeInterval) -> String {
    let clamped = max(0, time)
    let totalSeconds = Int(clamped.rounded())
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60

    if hours > 0 {
      return "\(hours):\(String(format: "%02d:%02d", minutes, seconds))"
    }

    return String(format: "%02d:%02d", minutes, seconds)
  }
}
