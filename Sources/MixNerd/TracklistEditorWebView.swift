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
  private let initialURL = URL(
    string:
      "https://www.1001tracklists.com/tracklist/2xbh9b9/armin-van-buuren-a-state-of-trance-000-2001-05-18.html"
  )!
  private let tracklistWebViewWidth = 400.0

  var body: some View {
    GeometryReader { geometry in
      HStack(alignment: .top, spacing: 0) {
        TracklistWebView(
          url: initialURL,
          setTracklist: { [state] tl in
            let tracklist = tl
            Task { @MainActor in
              state.setWebTracklist(tracklist)
            }
          }
        )
        .frame(width: geometry.size.width - tracklistWebViewWidth, height: geometry.size.height)
        .border(Color.gray.opacity(0.3))
        .clipped()

        // Divider()

        // HStack {
        //     VStack {
        //         if let tracklist = state.webTracklist {
        //             TracklistView(tracklist: Binding(get: { tracklist }, set: { state.setWebTracklist($0) }))
        //         } else {
        //             VStack(alignment: .leading, spacing: 8) {
        //                 Text("Not a track list page")
        //                     .font(.headline)
        //                 Text("Open a URL starting with \"https://www.1001tracklists.com/tracklist/\" to see track details.")
        //                     .foregroundColor(.secondary)
        //             }
        //             .padding()
        //         }
        //     }
        //     .frame(width: geometry.size.width * 0.5, height: tracklistWebViewHeight)

        VStack(alignment: .leading, spacing: 0) {
          HStack {
            Button("Open...") {
              // isOpeningFile = true
            }
            .controlSize(.small)
            .padding()

            Picker("", selection: Binding(get: { "Tracklist" }, set: { _ in })) {
              Text("Tracklist")
            }

            Button("Save") {
            }
            .controlSize(.small)
            .disabled(true)
            .padding()
          }
          .frame(maxWidth: .infinity)
          .frame(height: 30)

          TextTracklistView(
            tracklist: Binding(
              get: { state.webTracklist ?? Tracklist() }, set: { state.setWebTracklist($0) }),
            estimateMissingTrackTimes: $estimateMissingTrackTimes,
            includeLabels: $includeLabels
          )
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .frame(width: tracklistWebViewWidth)
      }
    }
  }
}
