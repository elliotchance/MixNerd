import AppKit

struct Tracklist: @unchecked Sendable {
  var artwork: Artwork
  var date: Date
  var artist: String
  var title: String
  var source: String
  var genre: String
  var comment: String
  var tracks: [Track]
  var grouping: String

  var artistComponent: String
  var titleComponent: String
  var genreComponent: String

  // e.g. https://1001.tl/1u7zqrvk
  var shortLink: URL?

  var duration: Time

  var audioFilePath: URL?

  init() {
    self.artwork = Artwork()
    self.date = Date()
    self.artist = ""
    self.title = ""
    self.source = ""
    self.genre = ""
    self.comment = ""
    self.tracks = []
    self.grouping = ""
    self.shortLink = nil
    self.duration = Time()
    self.audioFilePath = nil
    self.artistComponent = ""
    self.titleComponent = ""
    self.genreComponent = ""
  }

  init(
    artwork: Artwork,
    date: Date,
    artist: String,
    title: String,
    source: String,
    genre: String,
    comment: String,
    tracks: [Track],
    grouping: String,
    shortLink: URL?,
    duration: Time,
    audioFilePath: URL?,
    artistComponent: String,
    titleComponent: String,
    genreComponent: String,
  ) {
    self.artwork = artwork
    self.date = date
    self.artist = artist
    self.title = title
    self.source = source
    self.genre = genre
    self.comment = comment
    self.tracks = tracks
    self.grouping = grouping
    self.shortLink = shortLink
    self.duration = duration
    self.audioFilePath = audioFilePath
    self.artistComponent = artistComponent
    self.titleComponent = titleComponent
    self.genreComponent = genreComponent
  }

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
      grouping: grouping,
      shortLink: shortLink,
      duration: totalTime,
      audioFilePath: audioFilePath,
      artistComponent: artistComponent,
      titleComponent: titleComponent,
      genreComponent: genreComponent,
    )
  }
}
