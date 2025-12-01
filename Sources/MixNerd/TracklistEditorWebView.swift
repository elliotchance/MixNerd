import ID3TagEditor
import SwiftUI
import WebKit

class TracklistEditorState: ObservableObject, @unchecked Sendable {
  @Published var webTracklist: Tracklist?
  @Published var fileTracklist: Tracklist?

  @MainActor
  func setWebTracklist(_ tl: Tracklist?) {
    webTracklist = tl?.withCalculatedMissingTrackTimes() ?? nil
  }

  @MainActor
  func setFileTracklist(_ tl: Tracklist?) {
    fileTracklist = tl
  }
}

struct TracklistEditorWebView: View {
  @StateObject private var state = TracklistEditorState()
  @State private var isOpeningFile: Bool = false
  @State private var showAlert: Bool = false
  @State private var error: Error?
  @AppStorage("TextTracklistView_estimateMissingTrackTimes") private var estimateMissingTrackTimes:
    Bool = false
  @AppStorage("TextTracklistView_includeLabels") private var includeLabels: Bool = true
  private let initialURL = URL(string: "https://www.1001tracklists.com/")!
  private let tracklistWebViewWidth = 400.0
  @State private var pickerOptions: [String]
  @State private var selectedPickerOption: String
  private var audioFileCollection: AudioFileCollection = AudioFileCollection()
  @State private var tracklistWebView: TracklistWebView

  init() {
    pickerOptions = ["Tracklist", "Settings"]
    selectedPickerOption = "Tracklist"
    tracklistWebView = TracklistWebView(
      url: initialURL,
    )
  }

  func refreshPickerOptions() {
    pickerOptions = ["Tracklist"]
    for file in audioFileCollection.allAudioFiles() {
      pickerOptions.append(file.audioFilePath.lastPathComponent)
    }
    pickerOptions.append("Settings")
  }

  var body: some View {
    GeometryReader { geometry in
      HStack(alignment: .top, spacing: 0) {
        tracklistWebView
          .frame(width: geometry.size.width - tracklistWebViewWidth, height: geometry.size.height)
          .border(Color.gray.opacity(0.3))
          .clipped()

        VStack(alignment: .leading, spacing: 0) {
          HStack {
            Button("Open...") {
              isOpeningFile = true
            }
            .controlSize(.small)
            .padding()

            Picker("", selection: $selectedPickerOption) {
              ForEach(pickerOptions, id: \.self) { option in
                Text(option).tag(option)
              }
            }
            .padding()
          }
          .frame(maxWidth: .infinity)

          if selectedPickerOption == "Tracklist" {
            TextTracklistView(
              tracklist: Binding(
                get: { state.webTracklist ?? Tracklist() }, set: { state.setWebTracklist($0) }),
              estimateMissingTrackTimes: $estimateMissingTrackTimes,
              includeLabels: $includeLabels
            )
          } else if selectedPickerOption == "Settings" {
            SettingsView()
          } else {
            AudioFileEditorView(
              fileTracklist: Binding(
                get: {
                  audioFileCollection.audioFileByName(name: selectedPickerOption)?.tracklist
                    ?? Tracklist()
                },
                set: { state.setFileTracklist($0) }),
              webTracklist: Binding(
                get: { state.webTracklist ?? Tracklist() }, set: { state.setWebTracklist($0) }),
              searchForTracklist: { name in
                tracklistWebView.searchForTracklist(name: name)
              }
            )
          }
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .frame(width: tracklistWebViewWidth)
        .fileImporter(
          isPresented: $isOpeningFile,
          allowedContentTypes: [.folder],
          allowsMultipleSelection: false
        ) { result in
          switch result {
          case .success(let urls):
            guard let selectedURL = urls.first else { return }
            do {
              // Start accessing the security-scoped resource
              guard selectedURL.startAccessingSecurityScopedResource() else {
                throw NSError(
                  domain: "FileAccessError", code: 0,
                  userInfo: [NSLocalizedDescriptionKey: "Could not access the selected folder."])
              }
              defer {
                selectedURL.stopAccessingSecurityScopedResource()
              }

              // Scan mp3 and cue files in the folder
              let files = try FileManager.default.contentsOfDirectory(
                at: selectedURL, includingPropertiesForKeys: nil)
              // var foundTracklist: Tracklist?

              for file in files {
                if file.pathExtension == "mp3" {
                  audioFileCollection.addAudioFile(audioFilePath: file)
                }
                // if file.pathExtension == "cue" {
                //   let cueContent = try String(contentsOf: file, encoding: .utf8)
                //   if let cueFile = CueFile.parse(cueContent) {
                //     if foundTracklist != nil {
                //       foundTracklist?.tracks = cueFile.tracks
                //     } else {
                //       foundTracklist = cueFile
                //     }
                //   }
                // }
              }

              // if let tracklist = foundTracklist {
              //   state.setFileTracklist(tracklist)
              // }
            } catch {
              self.error = error
            }
          case .failure(let error):
            self.error = error
          }

          refreshPickerOptions()
        }
      }
    }
  }
}
