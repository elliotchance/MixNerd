class Settings {
  // DateFormat described how to format the date for audio file tags.
  static let DateFormatKey = "settings.date_format"
  static let DateFormatDefault = "YYYY-MM-DD"
  static let DateFormatValues = [
    "YYYY-MM-DD": "YYYY-MM-DD",
    "YYYY": "YYYY",
  ]

  static let DateInTitleKey = "settings.date_in_title"
  static let DateInTitleDefault = "Before"
  static let DateInTitleValues = [
    "Before": "Before (eg. Title 2025-01-02)",
    "After": "After (eg. 2025-01-02 Title)",
    "No date": "None (eg. Title)",
  ]

  static let MoveFilesKey = "settings.move_files"
  static let MoveFilesDefault = false

  static let DestinationKey = "settings.destination"
  static let DestinationDefault = ""

  static let FileNamingKey = "settings.file_naming"
  static let FileNamingDefault = ""

  static let AlbumFormatKey = "settings.album_format"
  static let AlbumFormatDefault = "{date} {title}"
}
