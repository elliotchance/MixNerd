import AppKit
import ID3TagEditor
import SwiftUI
import WebKit

struct AudioFileEditorView: View {
  @State private var isOpeningFile: Bool = false
  @State private var showAlert: Bool = false
  @State private var error: Error?
  @Binding var tracklist: Tracklist?
  let titleHeight = 30.0

  init(tracklist: Binding<Tracklist?>) {
    _tracklist = tracklist
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      //   HStack {
      //     Button("Save") {
      //     }
      //     .controlSize(.small)
      //     .disabled(fileName == nil)
      //     .padding()
      //   }
      //   .frame(maxWidth: .infinity)
      //   .frame(height: titleHeight)

      if var tracklist = tracklist {
        VStack(spacing: 0) {
          ArtworkView(artwork: Binding(get: { tracklist.artwork }, set: { _ in }))
            .frame(width: 200, height: 200)

          Form {
            TextField(
              "Album Artist",
              text: Binding(get: { tracklist.artist }, set: { tracklist.artist = $0 })
            )
            TextField(
              "Title", text: Binding(get: { tracklist.title }, set: { tracklist.title = $0 })
            )
            TextField(
              "Grouping", text: Binding(get: { tracklist.source }, set: { tracklist.source = $0 })
            )
            TextField(
              "Genre", text: Binding(get: { tracklist.genre }, set: { tracklist.genre = $0 })
            )
            TextField("Date", text: Binding(get: { tracklist.date }, set: { tracklist.date = $0 }))
            TextField(
              "Comment",
              text: Binding(get: { tracklist.shortLink }, set: { tracklist.shortLink = $0 }))
          }
          .padding()

          ScrollView {
            Form {
              ForEach(Array(tracklist.tracks.enumerated()), id: \.element.id) { index, track in
                HStack(alignment: .top) {
                  VStack {
                    Text(String(format: "%02d", index + 1)).font(.title3).bold()

                    if track.time != "" {
                      TextField("", text: Binding(get: { track.time }, set: { _ in }))
                        .frame(width: 80)
                        .font(.system(.body, design: .monospaced))
                        .multilineTextAlignment(.trailing)
                    } else {
                      TextField("", text: Binding(get: { "12:34" }, set: { _ in }))
                        .frame(width: 80)
                        .font(.system(.body, design: .monospaced))
                        .multilineTextAlignment(.trailing)
                        .background(Color.red.opacity(0.5))
                    }
                  }
                  VStack {
                    TextField("", text: Binding(get: { track.artist }, set: { _ in }))
                    TextField("", text: Binding(get: { track.title }, set: { _ in }))
                  }
                }
                Divider()
              }
            }
            .padding(.vertical)
            .padding(.horizontal)
          }
        }
      }
    }
    .frame(maxHeight: .infinity, alignment: .top)
    // .fileImporter(
    //   isPresented: $isOpeningFile,
    //   allowedContentTypes: [.folder],
    //   allowsMultipleSelection: false
    // ) { result in
    //   switch result {
    //   case .success(let urls):
    //     guard let selectedURL = urls.first else { return }
    //     do {
    //       // Start accessing the security-scoped resource
    //       guard selectedURL.startAccessingSecurityScopedResource() else {
    //         throw NSError(
    //           domain: "FileAccessError", code: 0,
    //           userInfo: [NSLocalizedDescriptionKey: "Could not access the selected folder."])
    //       }
    //       defer {
    //         selectedURL.stopAccessingSecurityScopedResource()
    //       }

    //       // Scan mp3 and cue files in the folder
    //       let files = try FileManager.default.contentsOfDirectory(
    //         at: selectedURL, includingPropertiesForKeys: nil)
    //       var foundTracklist: Tracklist?

    //       for file in files {
    //         if file.pathExtension == "mp3" {
    //           let id3TagEditor = ID3TagEditor()
    //           if let id3Tag = try id3TagEditor.read(from: file.path) {
    //             let tagContentReader = ID3TagContentReader(id3Tag: id3Tag)

    //             // Extract artwork if available
    //             var artwork: NSImage? = nil
    //             if let pictureFrame = id3Tag.frames[.attachedPicture(.frontCover)]
    //               as? ID3FrameAttachedPicture
    //             {
    //               let pictureData = pictureFrame.picture
    //               artwork = NSImage(data: pictureData)
    //             }

    //             foundTracklist = Tracklist(
    //               artwork: artwork,
    //               artist: stringValue(tagContentReader.artist()),
    //               title: stringValue(tagContentReader.title()),
    //               // source: stringValue(tagContentReader.itunesGrouping()),
    //             )
    //           }
    //           fileName = file.lastPathComponent
    //         }
    //         if file.pathExtension == "cue" {
    //           let cueContent = try String(contentsOf: file, encoding: .utf8)
    //           if let cueFile = CueFile.parse(cueContent) {
    //             if foundTracklist != nil {
    //               foundTracklist?.tracks = cueFile.tracks
    //             } else {
    //               foundTracklist = cueFile
    //             }
    //           }
    //         }
    //       }

    //       if let tracklist = foundTracklist {
    //         self.tracklist = tracklist
    //       }
    //     } catch {
    //       self.error = error
    //     }
    //   case .failure(let error):
    //     self.error = error
    //   }
    // }
    // .alert(isPresented: $showAlert, error: error) { _ in
    //     Button("OK") {
    //         // Handle acknowledgement.
    //     }
    // } message: { error in
    //     // Text(error.recoverySuggestion ?? "Try again later.")
    // }
  }

  func stringValue(_ s: String?) -> String {
    if let s = s {
      return s.replacingOccurrences(of: "\0", with: "")
    }
    return ""
  }
}
