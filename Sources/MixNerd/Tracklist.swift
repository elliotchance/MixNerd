import AppKit

struct Tracklist: @unchecked Sendable {
  var artwork: Artwork = Artwork()
  var date: Date = Date()
  var artist: String = ""
  var title: String = ""
  var source: String = ""
  var genre: String = ""
  var comment: String = ""
  var tracks: [Track] = []

  // e.g. https://1001.tl/1u7zqrvk
  var shortLink: URL?

  var duration: Time = Time()

  var audioFilePath: URL?

  func withEstimatedTrackTimes(totalTime: Time) -> Tracklist {
    guard !tracks.isEmpty else {
      return self
    }

    let times = tracks.map { $0.time }
    let estimator = TrackTimeEstimator()
    let estimatedTimes = estimator.estimate(times: times, totalTime: totalTime.at)

    var updatedTracks = tracks
    for (index, estimatedTime) in estimatedTimes.enumerated() {
      updatedTracks[index].time = estimatedTime
    }

    return Tracklist(
      artwork: artwork,
      date: date,
      artist: artist,
      title: title,
      source: source,
      genre: genre,
      comment: comment,
      tracks: updatedTracks,
      shortLink: shortLink,
      duration: totalTime,
      audioFilePath: audioFilePath,
    )
  }
}
