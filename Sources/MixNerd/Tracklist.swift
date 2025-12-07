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

  var duration: Time = Time()

  func withEstimatedTrackTimes(totalTime: Time) -> Tracklist {
    guard !tracks.isEmpty else {
      return self
    }

    let times = tracks.map { $0.time }
    let estimator = TrackTimeEstimator()
    let estimatedTimes = estimator.estimate(times: times, totalTime: duration.at)

    var updatedTracks = tracks
    for (index, estimatedTime) in estimatedTimes.enumerated() {
      // Only update if the original time was empty (at == 0 and not estimated)
      // if updatedTracks[index].time.at == 0 && !updatedTracks[index].time.isEstimated {
      updatedTracks[index].time = estimatedTime
      // }
    }

    return Tracklist(
      artwork: artwork,
      date: date,
      artist: artist,
      title: title,
      source: source,
      genre: genre,
      tracks: updatedTracks,
      shortLink: shortLink,
      duration: totalTime,
    )
  }
}
