import Foundation
import Testing

@testable import MixNerd

struct CueTrackTests {

  @Test
  func testContent_withZeroSeconds() {
    let track = CueTrack(performer: "Migdalor", title: "Realest Of The Real", time: .seconds(0))
    #expect(
      track.content(at: 1) == """
          TRACK 01 AUDIO
            PERFORMER "Migdalor"
            TITLE "Realest Of The Real"
            INDEX 01 0:00:00
        """)
  }

  @Test
  func testContent_withIndexAndSeconds() {
    let track = CueTrack(performer: "Atopia", title: "Between Two Worlds", time: .seconds(8))
    #expect(
      track.content(at: 13) == """
          TRACK 13 AUDIO
            PERFORMER "Atopia"
            TITLE "Between Two Worlds"
            INDEX 01 0:08:00
        """)
  }

  @Test
  func testContent_withMinutesAndSeconds() {
    let track = CueTrack(
      performer: "UltimateBlast & GK Music", title: "Freedom Master", time: .seconds(654))
    #expect(
      track.content(at: 13) == """
          TRACK 13 AUDIO
            PERFORMER "UltimateBlast & GK Music"
            TITLE "Freedom Master"
            INDEX 01 10:54:00
        """)
  }

  @Test
  func testContent_overOneHour() {
    let track = CueTrack(performer: "Free Falling", title: "My Destiny", time: .seconds(4000))
    #expect(
      track.content(at: 101) == """
          TRACK 101 AUDIO
            PERFORMER "Free Falling"
            TITLE "My Destiny"
            INDEX 01 66:40:00
        """)
  }
}
