import Foundation

struct AudioFile {
  // The path to the audio file
  var audioFilePath: URL

  // The path to the cue file, if if exists
  var cueFilePath: URL?
}
