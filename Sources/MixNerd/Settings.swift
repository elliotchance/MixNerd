class Settings {
  // Audio tagging
  static let ArtistFormatKey = "settings.artist_format"
  static let ArtistFormatDefault = "{artist}"

  static let AlbumFormatKey = "settings.album_format"
  static let AlbumFormatDefault = "{title}"

  static let GroupingFormatKey = "settings.grouping_format"
  static let GroupingFormatDefault = "{source}"

  static let GenreFormatKey = "settings.genre_format"
  static let GenreFormatDefault = "{genre}"

  static let CommentFormatKey = "settings.comment_format"
  static let CommentFormatDefault = "{shortLink}"

  // Renaming files
  static let RenameFilesKey = "settings.move_files"
  static let RenameFilesDefault = false

  static let RenameFileFormatKey = "settings.rename_file_format"
  static let RenameFileFormatDefault = "{date} {artist} - {title}"

  // Other files
  static let WriteCoverFileKey = "settings.write_cover_file"
  static let WriteCoverFileDefault = false

  static let WriteCueFileKey = "settings.write_cue_file"
  static let WriteCueFileDefault = true

  static let WriteURLFileKey = "settings.write_url_file"
  static let WriteURLFileDefault = false
}
