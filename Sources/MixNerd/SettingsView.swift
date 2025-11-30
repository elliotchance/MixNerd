import SwiftUI

struct SettingsView: View {
  @AppStorage(Settings.DateFormatKey) var dateFormat: String = Settings.DateFormatDefault
  @AppStorage(Settings.DateInTitleKey) var dateInTitle: String = Settings.DateInTitleDefault
  @AppStorage(Settings.MoveFilesKey) var moveFiles: Bool = false  // Settings.MoveFilesDefault
  @AppStorage(Settings.DestinationKey) var destination: String = ""  //Settings.DestinationDefault
  @AppStorage(Settings.FileNamingKey) var fileNaming: String = ""  // Settings.FileNamingDefault

  var body: some View {
    Form {
      Section(header: Text("File Tagging").font(.headline)) {
        Picker("Date Format", selection: $dateFormat) {
          ForEach(Settings.DateFormatValues.keys.sorted(), id: \.self) { key in
            Text(Settings.DateFormatValues[key]!).tag(key)
          }
        }
        Text("Choose how dates are formatted when added to audio file tags.")
          .font(.caption)
          .foregroundColor(.secondary)

        Picker("Date in Title", selection: $dateInTitle) {
          ForEach(Settings.DateInTitleValues.keys.sorted(), id: \.self) { key in
            Text(Settings.DateInTitleValues[key]!).tag(key)
          }
        }
      }

      Spacer().frame(height: 16)

      Section(header: Toggle("Move Files on Save", isOn: $moveFiles)) {
        HStack {
          TextField("Destination", text: $destination)
          Button("...") {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.begin { result in
              if result == .OK {
                destination = panel.url?.path ?? ""
              }
            }
          }
        }
        TextField("File Naming", text: $fileNaming)
      }
      .padding(.horizontal, 16)
    }
  }
}
