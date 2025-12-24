import Foundation

class AudioFileCollection {
  var audioFiles: [URL: AudioFile]

  init() {
    self.audioFiles = [:]
  }

  func addFolder(folderPath: URL) async throws {
    for file in try FileManager.default.contentsOfDirectory(
      at: folderPath, includingPropertiesForKeys: [.isDirectoryKey])
    {
      if file.pathExtension == "mp3" {
        try await addAudioFile(audioFilePath: file)
      }
      if let resourceValues = try? file.resourceValues(forKeys: [.isDirectoryKey]),
        resourceValues.isDirectory == true
      {
        try await addFolder(folderPath: file)
      }
    }
  }

  func addAudioFile(audioFilePath: URL) async throws {
    audioFiles[audioFilePath] = try await AudioFile(fromFilePath: audioFilePath)
  }

  func moveAudioFile(audioFile: AudioFile, to newPath: URL) throws {
    // Create the destination folders(s), if needed.
    let folderDestination = newPath.deletingLastPathComponent()
    try FileManager.default.createDirectory(
      at: folderDestination, withIntermediateDirectories: true, attributes: nil)

    // Move audio file.
    let oldAudioFilePath = audioFile.audioFilePath
    try FileManager.default.moveItem(at: oldAudioFilePath, to: newPath)
    audioFile.audioFilePath = newPath

    // Update the index.
    audioFiles[oldAudioFilePath] = nil
    audioFiles[newPath] = audioFile
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
    return allAudioFiles().first
  }

  func reset() {
    audioFiles = [:]
  }
}
