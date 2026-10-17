import Foundation
import Testing

@testable import MixNerd

@MainActor
struct TracklistEditorStateTests {
  func tracklist(trackCount: Int, duration: TimeInterval) -> Tracklist {
    var tl = Tracklist()
    tl.tracks = (0..<trackCount).map { _ in Track(time: Time(), artist: "", title: "") }
    tl.duration = Time(at: duration)
    return tl
  }

  @Test
  func testSetFileTracklist_reestimatesWebTracklist() {
    let state = TracklistEditorState()

    // Web tracklist loaded first, so estimates are based on the (wrong) 2 hour web duration.
    state.setWebTracklist(tracklist(trackCount: 4, duration: 7200), format: false)
    #expect(state.webTracklist?.tracks[1].time.description == "~30:00")

    // Opening the 1 hour file must re-estimate the web tracklist against the file duration.
    state.setFileTracklist(tracklist(trackCount: 0, duration: 3600))
    #expect(state.webTracklist?.duration.at == 3600)
    #expect(state.webTracklist?.tracks.map { $0.time.description } == [
      "00:00", "~15:00", "~30:00", "~45:00",
    ])
  }

  @Test
  func testSetFileTracklist_keepsKnownWebTimes() {
    let state = TracklistEditorState()

    var web = tracklist(trackCount: 4, duration: 7200)
    web.tracks[2].time = Time(string: "40:00")
    state.setWebTracklist(web, format: false)

    state.setFileTracklist(tracklist(trackCount: 0, duration: 3600))
    #expect(state.webTracklist?.tracks[2].time.description == "40:00")
    #expect(state.webTracklist?.tracks[2].time.isEstimated == false)
  }
}
