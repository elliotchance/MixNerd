import AVFoundation
import AppKit
import Foundation
import ID3TagEditor

class AudioFile {
  // The path to the audio file
  var audioFilePath: URL

  var tracklist: Tracklist?

  init(fromFilePath file: URL) async throws {
    audioFilePath = file

    let asset = AVURLAsset(url: file, options: nil)
    let id3TagEditor = ID3TagEditor()
    if let id3Tag = try? id3TagEditor.read(from: file.path) {
      let tagContentReader = ID3TagContentReader(id3Tag: id3Tag)

      let duration = try await asset.load(.duration)

      tracklist = Tracklist(
        artwork: Artwork(fromID3Tag: id3Tag),
        date: Date(fromID3TagContentReader: tagContentReader),
        artist: AudioFile.stringValue(tagContentReader.artist()),
        title: AudioFile.stringValue(tagContentReader.title()),
        source: "",
        genre: AudioFile.stringValue(tagContentReader.genre()?.description),
        comment: AudioFile.stringValue(tagContentReader.comments().first?.content),
        tracks: [],
        grouping: AudioFile.stringValue(tagContentReader.iTunesGrouping() ?? ""),
        shortLink: nil,
        duration: Time(at: TimeInterval(duration.seconds)),
        audioFilePath: audioFilePath,
        artistComponent: AudioFile.stringValue(tagContentReader.artist()),
        titleComponent: AudioFile.stringValue(tagContentReader.title()),
        genreComponent: AudioFile.stringValue(tagContentReader.genre()?.description),
      )
    }
  }

  /// Returns a new ID3Tag (which may lose some other fields). We only use the latest v2.4.
  /// I'm not sure if this should be intended or not.
  func id3Tag() -> ID3Tag {
    let id3Tag = ID32v4TagBuilder()

      // The title of the track and the album would be the same.
      .title(frame: ID3FrameWithStringContent(content: tracklist?.title ?? ""))
      .album(frame: ID3FrameWithStringContent(content: tracklist?.title ?? ""))

      // The track and album artist would also be the same.
      .albumArtist(frame: ID3FrameWithStringContent(content: tracklist?.artist ?? ""))
      .artist(frame: ID3FrameWithStringContent(content: tracklist?.artist ?? ""))

      // TODO: We should try to also set the genre if it matches the description, but this
      // is stll totally valid.
      .genre(frame: ID3FrameGenre(genre: nil, description: tracklist?.genre ?? ""))

      // There is contentGrouping and iTunesGrouping. It seems like the iTunes one is the
      // most sensible, but maybe we should set both?
      .iTunesGrouping(frame: ID3FrameWithStringContent(content: tracklist?.grouping ?? ""))

      // ID3v2.4 supports multiple comment frames with different languages.
      // I don't think the language is imporant, so we'll just choose eng for now.
      // Important: The contentDescription needs to be empty for other applications
      // to read content as a comment.
      .comment(
        language: .eng,
        frame: ID3FrameWithLocalizedContent(
          language: .eng,
          contentDescription: "",
          content: tracklist?.comment ?? ""
        ))

    if let date = tracklist?.date {
      _ = id3Tag.recordingDateTime(
        frame: date.toID3FrameRecordingDateTime()
      )
    }

    if let artwork = tracklist?.artwork {
      _ = id3Tag.attachedPicture(
        pictureType: .frontCover,
        frame: artwork.id3FrameAttachedPicture())
    }

    return id3Tag.build()
  }

  func save() throws {
    let id3TagEditor = ID3TagEditor()
    try id3TagEditor.write(tag: id3Tag(), to: audioFilePath.path)
  }

  static func stringValue(_ s: String?) -> String {
    if let s = s {
      return s.replacingOccurrences(of: "\0", with: "")
    }
    return ""
  }

  func cueFile() -> CueFile {
    return CueFile(
      performer: tracklist?.artist ?? "",
      title: tracklist?.title ?? "",
      file: audioFilePath.lastPathComponent,
      tracks: tracklist?.tracks.map {
        CueTrack(performer: $0.artist, title: $0.title, time: .seconds($0.time.at))
      } ?? [],
    )
  }

  func writeCUEFile() {
    let cueFilePath = audioFilePath.deletingPathExtension().appendingPathExtension("cue")
    let content = cueFile().content()
    try? content.write(to: cueFilePath, atomically: true, encoding: .utf8)
  }
}
