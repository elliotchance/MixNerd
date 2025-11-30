import Foundation

class AudioFileCollection {
  var audioFiles: [URL: AudioFile]

  init() {
    self.audioFiles = [:]
  }

  func addAudioFile(audioFilePath: URL) {
    audioFiles[audioFilePath] = AudioFile(audioFilePath: audioFilePath)
  }

  func allAudioFiles() -> [AudioFile] {
    return Array(audioFiles.values)
  }
}
