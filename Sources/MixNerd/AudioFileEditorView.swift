import AppKit
import SwiftUI
import WebKit

struct AudioFileEditorView: View {
  @State private var isOpeningFile: Bool = false
  @State private var showAlert: Bool = false
  @State private var error: Error?
  @Binding var fileTracklist: Tracklist
  @Binding var webTracklist: Tracklist  // TODO: Make this optional
  let titleHeight = 30.0
  let searchForTracklist: (String) -> Void
  let save: () throws -> Void

  init(
    fileTracklist: Binding<Tracklist>, webTracklist: Binding<Tracklist>,
    searchForTracklist: @escaping (String) -> Void,
    save: @escaping () throws -> Void,
  ) {
    _fileTracklist = fileTracklist
    _webTracklist = webTracklist
    self.searchForTracklist = searchForTracklist
    self.save = save
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      VStack(spacing: 0) {
        HStack {
          Button("Search 1001tracklists") {
            var searchString = "\(fileTracklist.artist) \(fileTracklist.title)"
            if searchString.isEmpty {
              searchString = fileTracklist.audioFilePath?.lastPathComponent ?? ""
            }
            searchForTracklist(searchString)
          }
          Button("Save") {
            do {
              try save()
            } catch let saveError {
              error = saveError
            }
          }
          .disabled(webTracklist.shortLink == nil)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom)

        if webTracklist.tracks.count > 0 {
          ArtworkView(artwork: Binding(get: { webTracklist.artwork }, set: { _ in }))
            .frame(width: 200, height: 200)

          Form {
            ToggleTextField(
              label: "Artist",
              oldValue: Binding(get: { fileTracklist.artist }, set: { fileTracklist.artist = $0 }),
              newValue: Binding(get: { webTracklist.artist }, set: { webTracklist.artist = $0 }),
            )
            ToggleTextField(
              label: "Album",
              oldValue: Binding(get: { fileTracklist.title }, set: { fileTracklist.title = $0 }),
              newValue: Binding(get: { webTracklist.title }, set: { webTracklist.title = $0 }),
            )
            ToggleTextField(
              label: "Grouping",
              oldValue: Binding(
                get: { fileTracklist.grouping }, set: { fileTracklist.grouping = $0 }),
              newValue: Binding(
                get: { webTracklist.grouping }, set: { webTracklist.grouping = $0 }),
            )
            ToggleTextField(
              label: "Genre",
              oldValue: Binding(get: { fileTracklist.genre }, set: { fileTracklist.genre = $0 }),
              newValue: Binding(get: { webTracklist.genre }, set: { webTracklist.genre = $0 }),
            )
            ToggleTextField(
              label: "Year",
              oldValue: Binding(
                get: { fileTracklist.date.year.description },
                set: { fileTracklist.date = Date(fromString: $0) }),
              newValue: Binding(
                get: { webTracklist.date.year.description },
                set: { webTracklist.date = Date(fromString: $0) }),
            )
            ToggleTextField(
              label: "Comment",
              oldValue: Binding(
                get: { fileTracklist.comment },
                set: { fileTracklist.comment = $0 }),
              newValue: Binding(
                get: { webTracklist.comment }, set: { webTracklist.comment = $0 }),
            )
          }
          .padding()

          let estimatedCount = webTracklist.tracks.filter { $0.time.isEstimated }.count
          let totalCount = webTracklist.tracks.count
          if estimatedCount > 1 {
            Text("\(estimatedCount)/\(totalCount) tracks have estimated times")
              .bold()
              .foregroundColor(.red)
              .padding(.bottom, 5)
          } else {
            Text("\(totalCount)/\(totalCount) have track times")
              .foregroundColor(.green)
              .padding(.bottom, 5)
          }

          ScrollView {
            Form {
              ForEach(Array(webTracklist.tracks.enumerated()), id: \.element.id) { index, track in
                HStack(alignment: .top) {
                  VStack {
                    Text(String(format: "%02d", index + 1)).font(.title3).bold()

                    TextField(
                      "",
                      text: Binding(
                        get: { trackAtIndex(webTracklist, index).time.exact.description },
                        set: { webTracklist.tracks[index].time = Time(string: $0) })
                    )
                    .background(
                      trackAtIndex(webTracklist, index).time.isEstimated
                        ? Color.red.opacity(0.3) : Color.clear
                    )
                    .frame(width: 60)
                    .multilineTextAlignment(.trailing)
                  }
                  VStack {
                    TextField(
                      "",
                      text: Binding(
                        get: { trackAtIndex(webTracklist, index).artist },
                        set: { webTracklist.tracks[index].artist = $0 })
                    )
                    TextField(
                      "",
                      text: Binding(
                        get: { trackAtIndex(webTracklist, index).title },
                        set: { webTracklist.tracks[index].title = $0 })
                    )
                  }
                }
              }
            }
            .padding(.vertical)
            .padding(.horizontal)
          }
        } else {
          Text("No tracklist found. Please navigate to a tracklist page.")
            .padding()
        }
      }
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .alert(
      "Error",
      isPresented: Binding(
        get: { error != nil },
        set: { if !$0 { error = nil } }
      )
    ) {
      Button("OK") {
        error = nil
      }
    } message: {
      if let error = error {
        Text(error.localizedDescription)
      }
    }
  }

  func trackAtIndex(_ tracklist: Tracklist, _ index: Int) -> Track {
    if index < tracklist.tracks.count {
      return tracklist.tracks[index]
    }
    return Track(time: Time(at: 0), artist: "", title: "")
  }
}
