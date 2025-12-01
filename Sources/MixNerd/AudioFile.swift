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
      // print("Tag content reader: \(tagContentReader)")
      // print("Artist: \(tagContentReader.artist())")
      // print("Title: \(tagContentReader.title())")

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
        artist: AudioFile.stringValue(tagContentReader.artist()),
        title: AudioFile.stringValue(tagContentReader.title()),
        // source: stringValue(tagContentReader.itunesGrouping()),
      )
    }
  }

  static func stringValue(_ s: String?) -> String {
    if let s = s {
      return s.replacingOccurrences(of: "\0", with: "")
    }
    return ""
  }
}
