import SwiftUI

struct SettingsView: View {
  @AppStorage(Settings.RenameFilesKey) var renameFiles: Bool = Settings.RenameFilesDefault
  @AppStorage(Settings.RenameFileFormatKey) var renameFileFormat: String = Settings
    .RenameFileFormatDefault

  @AppStorage(Settings.ArtistFormatKey) var artistFormat: String = Settings.ArtistFormatDefault
  @AppStorage(Settings.AlbumFormatKey) var albumFormat: String = Settings.AlbumFormatDefault
  @AppStorage(Settings.CommentFormatKey) var commentFormat: String = Settings.CommentFormatDefault
  @AppStorage(Settings.GroupingFormatKey) var groupingFormat: String = Settings
    .GroupingFormatDefault
  @AppStorage(Settings.GenreFormatKey) var genreFormat: String = Settings.GenreFormatDefault

  @AppStorage(Settings.WriteCoverFileKey) var writeCoverFile: Bool = Settings.WriteCoverFileDefault
  @AppStorage(Settings.WriteCueFileKey) var writeCueFile: Bool = Settings.WriteCueFileDefault
  @AppStorage(Settings.WriteURLFileKey) var writeURLFile: Bool = Settings.WriteURLFileDefault

  var body: some View {
    Form {
      Section(header: Text("Audio Tag Formatting").font(.headline)) {
        TextField("Artist", text: $artistFormat)
        TextField("Album", text: $albumFormat)
        TextField("Grouping", text: $groupingFormat)
        TextField("Genre", text: $genreFormat)
        TextField("Comment", text: $commentFormat)

        Text(
          """
          Placeholders:
          {artist} (eg. Armin van Buuren)
          {date} (eg. 2025-01-02)
          {genre} (eg. Trance)
          {shortLink} (eg. https://1001.tl/1u7zqrvk)
          {source} (eg. A State of Trance)
          {title} (eg. Title)
          {year} (eg. 2025)
          """
        )
        .font(.caption)
        .foregroundColor(.secondary)
      }

      Spacer().frame(height: 16)

      Section(header: Text("Other Files").font(.headline)) {
        Toggle("Write .cue file", isOn: $writeCueFile)
        Toggle("Write .url file", isOn: $writeURLFile)
        Toggle("Write cover.jpg file", isOn: $writeCoverFile)
      }

      Spacer().frame(height: 16)

      Section(header: Text("Rename Files").font(.headline)) {
        Toggle("Rename Files", isOn: $renameFiles)
        TextField("File Naming", text: $renameFileFormat)
          .disabled(!renameFiles)

        Text("Use placeholders described above.")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
  }
}
