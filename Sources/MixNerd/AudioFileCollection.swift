import Foundation

class AudioFileCollection {
  var audioFiles: [URL: AudioFile]

  init() {
    self.audioFiles = [:]
  }

  func addAudioFile(audioFilePath: URL) {
    audioFiles[audioFilePath] = AudioFile(fromFilePath: audioFilePath)
  }

  func audioFileByName(name: String) -> AudioFile? {
    return audioFiles.values.first { $0.audioFilePath.lastPathComponent == name }
  }

  func allAudioFiles() -> [AudioFile] {
    return Array(audioFiles.values).sorted {
      $0.audioFilePath.lastPathComponent < $1.audioFilePath.lastPathComponent
    }
  }

  func firstFile() -> AudioFile? {
    return audioFiles.values.first
  }

  func reset() {
    audioFiles = [:]
  }
}
