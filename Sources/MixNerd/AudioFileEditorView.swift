import SwiftUI
import WebKit
import ID3TagEditor
import AppKit

struct AudioFileEditorView: View {
    @State private var isOpeningFile: Bool = false
    @State private var showAlert: Bool = false
    @State private var error: Error?
    @State private var tracklist: Tracklist?
    @State private var fileName: String? = nil
    let titleHeight = 30.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button("Open...") {
                    isOpeningFile = true
                }
                .controlSize(.small)

                Text(fileName ?? "No MP3 file loaded")
                .frame(maxWidth: .infinity)
                .controlSize(.small)
                
                Button("Save") {
                }
                .controlSize(.small)
                .disabled(fileName == nil)
                .padding()
            }
            .frame(maxWidth: .infinity)
            .frame(height: titleHeight)

            if let tracklist = tracklist {
                TracklistView(tracklist: Binding(get: { tracklist }, set: { self.tracklist = $0 }))
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
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
                        throw NSError(domain: "FileAccessError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not access the selected folder."])
                    }
                    defer {
                        selectedURL.stopAccessingSecurityScopedResource()
                    }

                    // Scan mp3 and cue files in the folder
                    let files = try FileManager.default.contentsOfDirectory(at: selectedURL, includingPropertiesForKeys: nil)
                    var foundTracklist: Tracklist?
                    
                    for file in files {
                        if file.pathExtension == "mp3" {
                            let id3TagEditor = ID3TagEditor()
                            if let id3Tag = try id3TagEditor.read(from: file.path) {
                                let tagContentReader = ID3TagContentReader(id3Tag: id3Tag)
                                
                                // Extract artwork if available
                                var artwork: NSImage? = nil
                                if let pictureFrame = id3Tag.frames[.attachedPicture(.frontCover)] as? ID3FrameAttachedPicture {
                                    let pictureData = pictureFrame.picture
                                    artwork = NSImage(data: pictureData)
                                }
                                
                                foundTracklist = Tracklist(
                                    artwork: artwork,
                                    artist: stringValue(tagContentReader.artist()),
                                    title: stringValue(tagContentReader.title()),
                                    // source: stringValue(tagContentReader.itunesGrouping()),
                                    editable: true,
                                )
                            }
                            fileName = file.lastPathComponent
                        }
                        if file.pathExtension == "cue" {
                            let cueContent = try String(contentsOf: file, encoding: .utf8)
                            if let cueFile = CueFile.parse(cueContent) {
                                if foundTracklist != nil {
                                    foundTracklist?.tracks = cueFile.tracks
                                } else {
                                    foundTracklist = cueFile
                                }
                            }
                        }
                    }
                    
                    if let tracklist = foundTracklist {
                        self.tracklist = tracklist
                    }
                } catch {
                    self.error = error
                }
            case .failure(let error):
                self.error = error
            }
        }
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
