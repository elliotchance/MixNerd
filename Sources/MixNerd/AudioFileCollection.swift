import Foundation

class AudioFileCollection {
  var audioFiles: [URL: AudioFile]

  init() {
    self.audioFiles = [:]
  }

  func addFolder(folderPath: URL) {
    for file in FileManager.default.contentsOfDirectory(
      at: folderPath, includingPropertiesForKeys: nil)
    {
      if file.pathExtension == "mp3" {
        print("Adding audio file: \(file)")
        // addAudioFile(audioFilePath: file)
      }
      if file.isDirectory {
        addFolder(folderPath: file)
      }
    }
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
