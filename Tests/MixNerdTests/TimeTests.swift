import Foundation
import Testing

@testable import MixNerd

struct TimeTests {
  @Test
  func testInit_at() {
    let time = Time(at: 125.5)
    #expect(time.at == 125.5)
    #expect(time.isEstimated == false)
  }

  @Test
  func testInit_estimatedAt() {
    let time = Time(estimatedAt: 125.5)
    #expect(time.at == 125.5)
    #expect(time.isEstimated == true)
  }

  @Test
  func testInit_string_threeComponents() {
    let time = Time(string: "1:30:45")
    #expect(time.at == 5445.0)
    #expect(time.isEstimated == false)
  }

  @Test
  func testInit_string_threeComponents_zero() {
    let time = Time(string: "0:0:0")
    #expect(time.at == 0.0)
    #expect(time.isEstimated == false)
  }

  @Test
  func testInit_string_threeComponents_large() {
    let time = Time(string: "2:15:30")
    #expect(time.at == 8130.0)
    #expect(time.isEstimated == false)
  }

  @Test
  func testInit_string_twoComponents() {
    let time = Time(string: "2:30")
    #expect(time.at == 150.0)
    #expect(time.isEstimated == false)
  }

  @Test
  func testInit_string_twoComponents_zero() {
    let time = Time(string: "0:0")
    #expect(time.at == 0.0)
    #expect(time.isEstimated == false)
  }

  @Test
  func testInit_string_twoComponents_large() {
    let time = Time(string: "125:45")
    #expect(time.at == 7545.0)
    #expect(time.isEstimated == false)
  }

  @Test
  func testInit_string_oneComponent() {
    let time = Time(string: "45")
    #expect(time.at == 45.0)
    #expect(time.isEstimated == false)
  }

  @Test
  func testInit_string_oneComponent_zero() {
    let time = Time(string: "0")
    #expect(time.at == 0.0)
    #expect(time.isEstimated == false)
  }

  @Test
  func testInit_string_oneComponent_large() {
    let time = Time(string: "3661")
    #expect(time.at == 3661.0)
    #expect(time.isEstimated == false)
  }

  @Test
  func testDescription_zeroSeconds() {
    let time = Time(at: 0)
    #expect(time.description == "00:00")
  }

  @Test
  func testDescription_zeroSeconds_estimated() {
    let time = Time(estimatedAt: 0)
    #expect(time.description == "~00:00")
  }

  @Test
  func testDescription_secondsOnly() {
    let time = Time(at: 30)
    #expect(time.description == "00:30")
  }

  @Test
  func testDescription_secondsOnly_estimated() {
    let time = Time(estimatedAt: 30)
    #expect(time.description == "~00:30")
  }

  @Test
  func testDescription_minutesAndSeconds() {
    let time = Time(at: 125)
    #expect(time.description == "02:05")
  }

  @Test
  func testDescription_minutesAndSeconds_estimated() {
    let time = Time(estimatedAt: 125)
    #expect(time.description == "~02:05")
  }

  @Test
  func testDescription_exactlyOneMinute() {
    let time = Time(at: 60)
    #expect(time.description == "01:00")
  }

  @Test
  func testDescription_exactlyOneHour() {
    let time = Time(at: 3600)
    #expect(time.description == "1:00:00")
  }

  @Test
  func testDescription_exactlyOneHour_estimated() {
    let time = Time(estimatedAt: 3660)
    #expect(time.description == "~1:01:00")
  }

  @Test
  func testDescription_hoursMinutesSeconds() {
    let time = Time(at: 3661)
    #expect(time.description == "1:01:01")
  }

  @Test
  func testDescription_hoursMinutesSeconds_estimated() {
    let time = Time(estimatedAt: 3661)
    #expect(time.description == "~1:01:01")
  }

  @Test
  func testDescription_multipleHours() {
    let time = Time(at: 7323)
    #expect(time.description == "2:02:03")
  }

  @Test
  func testDescription_multipleHours_estimated() {
    let time = Time(estimatedAt: 7323)
    #expect(time.description == "~2:02:03")
  }

  @Test
  func testDescription_fractionalSeconds() {
    let time = Time(at: 125.7)
    #expect(time.description == "02:05")
  }

  @Test
  func testDescription_fractionalSeconds_estimated() {
    let time = Time(estimatedAt: 125.7)
    #expect(time.description == "~02:05")
  }

  @Test
  func testDescription_largeTime() {
    let time = Time(at: 123456)
    #expect(time.description == "34:17:36")
  }

  @Test
  func testDescription_largeTime_estimated() {
    let time = Time(estimatedAt: 123456)
    #expect(time.description == "~34:17:36")
  }
}
