import ID3TagEditor
import SwiftUI
import WebKit

class TracklistEditorState: ObservableObject, @unchecked Sendable {
  @Published var webTracklist: Tracklist?
  @Published var fileTracklist: Tracklist?

  @MainActor
  func setWebTracklist(_ tl: Tracklist?) {
    webTracklist = tl?.withEstimatedTrackTimes(totalTime: webTracklist?.duration ?? Time()) ?? nil
  }

  @MainActor
  func setFileTracklist(_ tl: Tracklist?) {
    fileTracklist = tl?.withEstimatedTrackTimes(totalTime: fileTracklist?.duration ?? Time()) ?? nil
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
  @State private var duration: String = ""
  private var audioFileCollection: AudioFileCollection = AudioFileCollection()
  @State private var tracklistWebView: TracklistWebView?
  @State private var destinationFolder: URL?

  init() {
    pickerOptions = ["Tracklist", "Settings"]
    selectedPickerOption = "Tracklist"
  }

  @MainActor
  private func makeTracklistWebView() -> TracklistWebView {
    let stateRef = state
    return TracklistWebView(
      url: initialURL,
      setTracklist: { tracklist in
        Task { @MainActor in
          stateRef.setWebTracklist(tracklist)
        }
      }
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
        if let tracklistWebView = tracklistWebView {
          tracklistWebView
            .frame(width: geometry.size.width - tracklistWebViewWidth, height: geometry.size.height)
            .border(Color.gray.opacity(0.3))
            .clipped()
        }

        VStack(alignment: .leading, spacing: 0) {
          HStack {
            Button("Open...") {
              isOpeningFile = true
            }
            .padding(.vertical)
            .padding(.leading)

            Picker("", selection: $selectedPickerOption) {
              ForEach(pickerOptions, id: \.self) { option in
                Text(option).tag(option)
              }
            }
            .padding(.vertical)
            .padding(.trailing)
          }
          .frame(maxWidth: .infinity)

          if selectedPickerOption == "Tracklist" {
            TextTracklistView(
              tracklist: Binding(
                get: { state.webTracklist ?? Tracklist() }, set: { state.setWebTracklist($0) }),
              estimateMissingTrackTimes: $estimateMissingTrackTimes,
              includeLabels: $includeLabels,
              duration: $duration
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
                tracklistWebView?.searchForTracklist(name: name)
              },
              save: {
                if let audioFile = audioFileCollection.audioFileByName(name: selectedPickerOption),
                  let destinationFolder = destinationFolder
                {
                  if let tracklist = state.webTracklist {
                    // Save the file in place first.
                    audioFile.tracklist = tracklist
                    try audioFile.save()

                    // Now move and write other files.
                    do {
                      let fileDestination = destinationFolder.appendingPathComponent(
                        PathFormatter().format(
                          path:
                            "{source}/{year}/{date} {artist} - {title}/{date} {artist} - {title}",
                          tracklist: tracklist))
                      let folderDestination = fileDestination.deletingLastPathComponent()

                      try FileManager.default.createDirectory(
                        at: folderDestination, withIntermediateDirectories: true, attributes: nil)

                      let audioFilePath = fileDestination.appendingPathExtension("mp3")
                      try FileManager.default.moveItem(
                        at: audioFile.audioFilePath, to: audioFilePath)
                      audioFile.audioFilePath = audioFilePath

                      let coverPath = folderDestination.appendingPathComponent("cover.jpg")
                      tracklist.artwork.write(toFile: coverPath.path)

                      audioFile.writeCUEFile()

                      if let shortLink = tracklist.shortLink {
                        tracklist.shortLink?.writeInternetShortcut(
                          to: folderDestination.appendingPathComponent(
                            "\(shortLink.lastPathComponent).url"))
                      }
                    } catch {
                      print("Error saving files: \(error)")
                      throw error
                    }
                  }
                }
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
            guard let selectedFolder = urls.first else { return }
            destinationFolder = selectedFolder
            do {
              // Start accessing the security-scoped resource
              guard selectedFolder.startAccessingSecurityScopedResource() else {
                throw NSError(
                  domain: "FileAccessError", code: 0,
                  userInfo: [NSLocalizedDescriptionKey: "Could not access the selected folder."])
              }
              defer {
                selectedFolder.stopAccessingSecurityScopedResource()
              }

              audioFileCollection.reset()

              let files = try FileManager.default.contentsOfDirectory(
                at: selectedFolder, includingPropertiesForKeys: nil)

              for file in files {
                if file.pathExtension == "mp3" {
                  audioFileCollection.addAudioFile(audioFilePath: file)
                }
              }

              if let firstFile = audioFileCollection.firstFile() {
                selectedPickerOption = firstFile.audioFilePath.lastPathComponent
                state.setFileTracklist(firstFile.tracklist)
              }
            } catch {
              self.error = error
            }
          case .failure(let error):
            self.error = error
          }

          refreshPickerOptions()
        }
      }
      .onAppear {
        if tracklistWebView == nil {
          tracklistWebView = makeTracklistWebView()
        }
      }
      .onChange(of: state.webTracklist?.duration.exact.description ?? "") { oldValue, newValue in
        duration = newValue
      }
    }
  }
}
