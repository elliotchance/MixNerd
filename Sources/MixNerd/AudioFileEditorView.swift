import AppKit
import SwiftUI
import WebKit

struct AudioFileEditorView: View {
  @State private var isOpeningFile: Bool = false
  @State private var showAlert: Bool = false
  @State private var error: Error?
  @Binding var fileTracklist: Tracklist
  @Binding var webTracklist: Tracklist
  let titleHeight = 30.0
  let searchForTracklist: (String) -> Void
  let save: () -> Void

  init(
    fileTracklist: Binding<Tracklist>, webTracklist: Binding<Tracklist>,
    searchForTracklist: @escaping (String) -> Void,
    save: @escaping () -> Void,
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
            searchForTracklist("\(fileTracklist.artist) \(fileTracklist.title)")
          }
          Button("Save") {
            save()
          }
        }
        .padding(.bottom)

        ArtworkView(artwork: Binding(get: { webTracklist.artwork }, set: { _ in }))
          .frame(width: 200, height: 200)

        Form {
          ToggleTextField(
            label: "Album Artist",
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
            oldValue: Binding(get: { fileTracklist.source }, set: { fileTracklist.source = $0 }),
            newValue: Binding(get: { webTracklist.source }, set: { webTracklist.source = $0 }),
          )
          ToggleTextField(
            label: "Genre",
            oldValue: Binding(get: { fileTracklist.genre }, set: { fileTracklist.genre = $0 }),
            newValue: Binding(get: { webTracklist.genre }, set: { webTracklist.genre = $0 }),
          )
          ToggleTextField(
            label: "Date",
            oldValue: Binding(
              get: { fileTracklist.date.description },
              set: { fileTracklist.date = Date(fromString: $0) }),
            newValue: Binding(
              get: { webTracklist.date.description },
              set: { webTracklist.date = Date(fromString: $0) }),
          )
          ToggleTextField(
            label: "Comment",
            oldValue: Binding(
              get: { fileTracklist.shortLink }, set: { fileTracklist.shortLink = $0 }),
            newValue: Binding(
              get: { webTracklist.shortLink }, set: { webTracklist.shortLink = $0 }),
          )
        }
        .padding()

        ScrollView {
          Form {
            ForEach(Array(webTracklist.tracks.enumerated()), id: \.element.id) { index, track in
              HStack(alignment: .top) {
                VStack {
                  Text(String(format: "%02d", index + 1)).font(.title3).bold()

                  ToggleTextField(
                    label: "",
                    oldValue: Binding(
                      get: { trackAtIndex(fileTracklist, index).time }, set: { _ in }),
                    newValue: Binding(
                      get: { trackAtIndex(webTracklist, index).time },
                      set: { webTracklist.tracks[index].time = $0 }),
                  )
                  .frame(width: 80)
                  .font(.system(.body, design: .monospaced))
                  .multilineTextAlignment(.trailing)
                }
                VStack {
                  ToggleTextField(
                    label: "",
                    oldValue: Binding(
                      get: { trackAtIndex(fileTracklist, index).artist }, set: { _ in }),
                    newValue: Binding(
                      get: { trackAtIndex(webTracklist, index).artist },
                      set: { webTracklist.tracks[index].artist = $0 }),
                  )
                  ToggleTextField(
                    label: "",
                    oldValue: Binding(
                      get: { trackAtIndex(fileTracklist, index).title }, set: { _ in }),
                    newValue: Binding(
                      get: { trackAtIndex(webTracklist, index).title },
                      set: { webTracklist.tracks[index].title = $0 }),
                  )
                }
              }
            }
          }
          .padding(.vertical)
          .padding(.horizontal)
        }
      }
    }
    .frame(maxHeight: .infinity, alignment: .top)
    // .alert(isPresented: $showAlert, error: error) { _ in
    //     Button("OK") {
    //         // Handle acknowledgement.
    //     }
    // } message: { error in
    //     // Text(error.recoverySuggestion ?? "Try again later.")
    // }
  }

  func trackAtIndex(_ tracklist: Tracklist, _ index: Int) -> Track {
    if index < tracklist.tracks.count {
      return tracklist.tracks[index]
    }
    return Track(time: "", artist: "", title: "")
  }
}
