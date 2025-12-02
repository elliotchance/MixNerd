import AVFoundation
import AppKit
import Foundation
import ID3TagEditor

class AudioFile {
  // The path to the audio file
  var audioFilePath: URL

  // The path to the cue file, if if exists
  var cueFilePath: URL?

  var tracklist: Tracklist?

  init(fromFilePath file: URL) {
    audioFilePath = file

    let id3TagEditor = ID3TagEditor()
    if let id3Tag = try? id3TagEditor.read(from: file.path) {
      let tagContentReader = ID3TagContentReader(id3Tag: id3Tag)

      // Extract artwork if available
      var artwork: NSImage?
      if let pictureFrame = id3Tag.frames[.attachedPicture(.frontCover)]
        as? ID3FrameAttachedPicture
      {
        let pictureData = pictureFrame.picture
        artwork = NSImage(data: pictureData)
      }

      tracklist = Tracklist(
        artwork: artwork,
        date: AudioFile.stringValue(tagContentReader.recordingYear()?.description),
        artist: AudioFile.stringValue(tagContentReader.artist()),
        title: AudioFile.stringValue(tagContentReader.title()),
        source: AudioFile.stringValue(tagContentReader.iTunesGrouping() ?? ""),
        genre: AudioFile.stringValue(tagContentReader.genre()?.description),
        duration: TimeInterval(tagContentReader.lengthInMilliseconds() ?? 0) / 1000,

        // TODO: Could be extracted from the comment - if that's needed?
        // shortLink: "",
      )
    }
  }

  func save() {
    let id3TagEditor = ID3TagEditor()
    let id3Tag = ID32v3TagBuilder()
      .title(frame: ID3FrameWithStringContent(content: tracklist?.title ?? ""))
      .album(frame: ID3FrameWithStringContent(content: tracklist?.title ?? ""))
      // .albumArtist(frame: ID3FrameWithStringContent(content: tracklist?.artist ?? ""))
      .artist(frame: ID3FrameWithStringContent(content: tracklist?.artist ?? ""))
      .genre(frame: ID3FrameGenre(genre: nil, description: tracklist?.genre ?? ""))
      .iTunesGrouping(frame: ID3FrameWithStringContent(content: tracklist?.source ?? ""))
    // .recordingDayMonth(frame: ID3FrameRecordingDayMonth(day: 5, month: 8))
    // .recordingYear(frame: ID3FrameWithIntegerContent(year: Int(tracklist?.date ?? "")))

    if let artwork = tracklist?.artwork,
      let bits = artwork.representations.first as? NSBitmapImageRep
    {
      id3Tag.attachedPicture(
        pictureType: .frontCover,
        frame: ID3FrameAttachedPicture(
          picture: bits.representation(using: .jpeg, properties: [:]) ?? Data(),
          type: .frontCover,
          format: .jpeg))
    }

    // .comment(language: .ita, frame: ID3FrameWithLocalizedContent(language: ID3FrameContentLanguage.ita, contentDescription: "CD", content: "v2 ita comment"))
    // .comment(language: .eng, frame: ID3FrameWithLocalizedContent(language: ID3FrameContentLanguage.eng, contentDescription: "CD", content: "v2 eng comment"))

    try? id3TagEditor.write(tag: id3Tag.build(), to: audioFilePath.path)

    // let id3TagEditor = ID3TagEditor()
    // if let id3Tag = try? id3TagEditor.read(from: audioFilePath.path) {
    //   id3TagEditor.
    //   let tagContentReader = ID3TagContentReader(id3Tag: id3Tag)
    //   tagContentReader.setArtist(tracklist?.artist)
    //   tagContentReader.setTitle(tracklist?.title)
    //   // tagContentReader.setiTunesGrouping(tracklist?.source)
    //   // tagContentReader.setGenre(tracklist?.genre)
    //   // tagContentReader.setRecordingYear(tracklist?.date)
    //   // tagContentReader.setComment(tracklist?.shortLink)
    //   // tagContentReader.setAttachedPicture(.frontCover, picture: tracklist?.artwork?.pngData() ?? Data())
    //   // tagContentReader.setDuration(tracklist?.duration)
    //   // tagContentReader.setTrackNumber(tracklist?.tracks.count)

    //   try? id3TagEditor.write(tag: id3Tag, to: audioFilePath.path)
    // }
  }

  static func stringValue(_ s: String?) -> String {
    if let s = s {
      return s.replacingOccurrences(of: "\0", with: "")
    }
    return ""
  }
}
