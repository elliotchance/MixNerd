import Foundation

enum MixNerdError: LocalizedError {
  /// A track's known (non-estimated) start time is significantly later than the actual
  /// duration of the local audio file. This usually means the linked audio stream on
  /// 1001tracklists is longer than the file on disk, which would otherwise produce a
  /// CUE file with tracks pointing past the end of the audio.
  case trackTimeExceedsFileDuration(trackNumber: Int, trackTime: TimeInterval, fileDuration: TimeInterval)

  var errorDescription: String? {
    switch self {
    case .trackTimeExceedsFileDuration(let trackNumber, let trackTime, let fileDuration):
      return
        "Track \(trackNumber) starts at \(Time(at: trackTime).description), which is past the "
        + "end of the audio file (\(Time(at: fileDuration).description)). The linked track "
        + "times are likely longer than the actual file. No CUE file was written."
    }
  }
}
