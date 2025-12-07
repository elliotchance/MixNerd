import ID3TagEditor
import SwiftUI
import WebKit

class TracklistEditorState: ObservableObject, @unchecked Sendable {
  @Published var webTracklist: Tracklist?
  @Published var fileTracklist: Tracklist?

  @AppStorage(Settings.ArtistFormatKey) private var artistFormat: String = Settings
    .ArtistFormatDefault
  @AppStorage(Settings.AlbumFormatKey) private var albumFormat: String = Settings.AlbumFormatDefault
  @AppStorage(Settings.GenreFormatKey) private var genreFormat: String = Settings.GenreFormatDefault
  @AppStorage(Settings.GroupingFormatKey) private var groupingFormat: String = Settings
    .GroupingFormatDefault
  @AppStorage(Settings.CommentFormatKey) private var commentFormat: String = Settings
    .CommentFormatDefault

  @MainActor
  func setWebTracklist(_ tl: Tracklist?, format: Bool) {
    if var tl = tl {
      if format {
        let formatter = TracklistFormatter()
        tl.artist = formatter.format(tracklist: tl, format: artistFormat, escapeForPath: false)  // Artist
        tl.title = formatter.format(tracklist: tl, format: albumFormat, escapeForPath: false)  // Album
        tl.genre = formatter.format(tracklist: tl, format: genreFormat, escapeForPath: false)  // Genre
        tl.grouping = formatter.format(tracklist: tl, format: groupingFormat, escapeForPath: false)  // Grouping
        tl.comment = formatter.format(tracklist: tl, format: commentFormat, escapeForPath: false)  // Comment
      }

      webTracklist = tl.withEstimatedTrackTimes(totalTime: tl.duration)
    } else {
      webTracklist = nil
    }
  }

  @MainActor
  func setFileTracklist(_ tl: Tracklist?) {
    if let tl = tl {
      fileTracklist = tl.withEstimatedTrackTimes(totalTime: tl.duration)
    } else {
      fileTracklist = nil
    }
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
  @StateObject private var navigationState = NavigationState()
  @State private var urlText: String = ""
  @State private var destinationFolder: URL?

  @AppStorage(Settings.RenameFilesKey) private var renameFiles: Bool = Settings.RenameFilesDefault
  @AppStorage(Settings.RenameFileFormatKey) private var renameFileFormat: String = Settings
    .RenameFileFormatDefault
  @AppStorage(Settings.WriteCueFileKey) private var writeCueFile: Bool = Settings
    .WriteCueFileDefault
  @AppStorage(Settings.WriteURLFileKey) private var writeURLFile: Bool = Settings
    .WriteURLFileDefault
  @AppStorage(Settings.WriteCoverFileKey) private var writeCoverFile: Bool = Settings
    .WriteCoverFileDefault

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
          stateRef.setWebTracklist(tracklist, format: true)
        }
      },
      navigationState: navigationState
    )
  }

  func refreshPickerOptions() {
    pickerOptions = ["Tracklist"]

    for file in audioFileCollection.allAudioFiles() {
      pickerOptions.append(file.audioFilePath.lastPathComponent)
    }

    pickerOptions.append("Settings")
  }

  private func extractURL(from text: String) -> URL? {
    let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let range = NSRange(text.startIndex..., in: text)
    let matches = detector?.matches(in: text, options: [], range: range)

    if let firstMatch = matches?.first, let url = firstMatch.url {
      return url
    }

    return nil
  }

  @MainActor
  private func navigateToURLFromSelectedFile() {
    if let audioFile = audioFileCollection.audioFileByName(name: selectedPickerOption) {
      let comment = audioFile.tracklist?.comment ?? ""
      if let url = extractURL(from: comment) {
        tracklistWebView?.navigateToURL(url)
      }
    }
  }

  @MainActor
  private func navigateToURLString(_ urlString: String) {
    var urlString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

    // Add https:// if no scheme is present
    if !urlString.contains("://") {
      urlString = "https://" + urlString
    }

    if let url = URL(string: urlString) {
      tracklistWebView?.navigateToURL(url)
    }
  }

  var body: some View {
    GeometryReader { geometry in
      HStack(alignment: .top, spacing: 0) {
        if let tracklistWebView = tracklistWebView {
          VStack(spacing: 0) {
            // Navigation bar
            HStack(spacing: 8) {
              Button(action: {
                tracklistWebView.goBack()
              }) {
                Image(systemName: "chevron.left")
              }
              .buttonStyle(.borderless)
              .disabled(!navigationState.canGoBack)

              Button(action: {
                tracklistWebView.goForward()
              }) {
                Image(systemName: "chevron.right")
              }
              .buttonStyle(.borderless)
              .disabled(!navigationState.canGoForward)

              Button(action: {
                tracklistWebView.reload()
              }) {
                Image(systemName: "arrow.clockwise")
              }
              .buttonStyle(.borderless)

              TextField("URL", text: $urlText)
                .textFieldStyle(.plain)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(4)
                .overlay(
                  RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .onSubmit {
                  navigateToURLString(urlText)
                }

              Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor))
            .border(Color.gray.opacity(0.2), width: 1)

            tracklistWebView
              .frame(
                width: geometry.size.width - tracklistWebViewWidth,
                height: geometry.size.height - 40
              )
              .border(Color.gray.opacity(0.3))
              .clipped()
          }
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
                get: { state.webTracklist ?? Tracklist() },
                set: { state.setWebTracklist($0, format: false) }),
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
                get: { state.webTracklist ?? Tracklist() },
                set: { state.setWebTracklist($0, format: false) }),
              searchForTracklist: { name in
                tracklistWebView?.searchForTracklist(name: name)
              },
              audioDirectory: destinationFolder,
              save: {
                if let audioFile = audioFileCollection.audioFileByName(name: selectedPickerOption),
                  let destinationFolder = destinationFolder
                {
                  if let tracklist = state.webTracklist {
                    // Save the file in place first.
                    audioFile.tracklist = tracklist
                    try audioFile.save()

                    do {
                      var folderDestination = destinationFolder

                      if renameFiles {
                        let fileDestination = destinationFolder.appendingPathComponent(
                          TracklistFormatter().format(
                            tracklist: tracklist,
                            format: renameFileFormat,
                            escapeForPath: true))

                        try audioFileCollection.moveAudioFile(
                          audioFile: audioFile,
                          to: fileDestination.appendingPathExtension("mp3"))

                        refreshPickerOptions()
                        selectedPickerOption = audioFile.audioFilePath.lastPathComponent
                        state.setFileTracklist(audioFile.tracklist)

                        // In case the file was moved, we need to use this folder for any other
                        // optional files.
                        folderDestination = audioFile.audioFilePath.deletingLastPathComponent()
                      }

                      if writeCoverFile {
                        let coverPath = folderDestination.appendingPathComponent("cover.jpg")
                        tracklist.artwork.write(toFile: coverPath.path)
                      }

                      if writeCueFile {
                        // Cue file is written to the same folder as the audio file,
                        // which was updated if renamed above.
                        audioFile.writeCUEFile()
                      }

                      if writeURLFile {
                        if let shortLink = tracklist.shortLink {
                          tracklist.shortLink?.writeInternetShortcut(
                            to: folderDestination.appendingPathComponent(
                              "\(shortLink.lastPathComponent).url"))
                        }
                      }
                    } catch {
                      // TODO: Show this to the user.
                      throw error
                    }
                  }
                }
              }
            )
            .onChange(of: selectedPickerOption) { _, newValue in
              navigateToURLFromSelectedFile()
            }
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

              try audioFileCollection.addFolder(folderPath: selectedFolder)

              refreshPickerOptions()

              if let firstFile = audioFileCollection.firstFile() {
                selectedPickerOption = firstFile.audioFilePath.lastPathComponent
                state.setFileTracklist(firstFile.tracklist)
                navigateToURLFromSelectedFile()
              }
            } catch {
              self.error = error
            }
          case .failure(let error):
            self.error = error
          }
        }
      }
      .onAppear {
        if tracklistWebView == nil {
          tracklistWebView = makeTracklistWebView()
          urlText = initialURL.absoluteString
        }
      }
      .onChange(of: navigationState.currentURL) { _, newURL in
        if let url = newURL {
          urlText = url.absoluteString
        }
      }
      .onChange(of: state.webTracklist?.duration.exact.description ?? "") { oldValue, newValue in
        duration = newValue
      }
    }
  }
}
