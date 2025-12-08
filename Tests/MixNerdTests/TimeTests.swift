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
    #expect(time.at == 0.0)
    #expect(time.isEstimated == true)
  }

  @Test
  func testInit_string_oneComponent_zero() {
    let time = Time(string: "0")
    #expect(time.at == 0.0)
    #expect(time.isEstimated == true)
  }

  @Test
  func testInit_string_oneComponent_large() {
    let time = Time(string: "3661")
    #expect(time.at == 0.0)
    #expect(time.isEstimated == true)
  }

  @Test
  func testInit_string_empty() {
    let time = Time(string: "")
    #expect(time.at == 0.0)
    #expect(time.isEstimated == true)
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

  @Test
  func testIsValidTimeString_empty() {
    #expect(Time.isValidTimeString("") == false)
  }

  @Test
  func testIsValidTimeString_singleComponent() {
    #expect(Time.isValidTimeString("45") == false)
  }

  @Test
  func testIsValidTimeString_singleComponent_zero() {
    #expect(Time.isValidTimeString("0") == false)
  }

  @Test
  func testIsValidTimeString_singleComponent_decimal() {
    #expect(Time.isValidTimeString("125.5") == false)
  }

  @Test
  func testIsValidTimeString_twoComponents() {
    #expect(Time.isValidTimeString("2:30") == true)
  }

  @Test
  func testIsValidTimeString_twoComponents_zero() {
    #expect(Time.isValidTimeString("0:0") == true)
  }

  @Test
  func testIsValidTimeString_twoComponents_decimal() {
    #expect(Time.isValidTimeString("2.5:30.7") == false)
  }

  @Test
  func testIsValidTimeString_threeComponents() {
    #expect(Time.isValidTimeString("1:30:45") == true)
  }

  @Test
  func testIsValidTimeString_threeComponents_zero() {
    #expect(Time.isValidTimeString("0:0:0") == true)
  }

  @Test
  func testIsValidTimeString_threeComponents_decimal() {
    #expect(Time.isValidTimeString("1.5:30.2:45.8") == false)
  }

  @Test
  func testIsValidTimeString_twoComponents_firstDecimal() {
    #expect(Time.isValidTimeString("2.5:30") == false)
  }

  @Test
  func testIsValidTimeString_twoComponents_secondDecimal() {
    #expect(Time.isValidTimeString("2:30.7") == false)
  }

  @Test
  func testIsValidTimeString_threeComponents_firstDecimal() {
    #expect(Time.isValidTimeString("1.5:30:45") == false)
  }

  @Test
  func testIsValidTimeString_threeComponents_secondDecimal() {
    #expect(Time.isValidTimeString("1:30.2:45") == false)
  }

  @Test
  func testIsValidTimeString_threeComponents_thirdDecimal() {
    #expect(Time.isValidTimeString("1:30:45.8") == false)
  }

  @Test
  func testIsValidTimeString_moreThanThreeComponents() {
    #expect(Time.isValidTimeString("1:2:3:4") == false)
  }

  @Test
  func testIsValidTimeString_fiveComponents() {
    #expect(Time.isValidTimeString("1:2:3:4:5") == false)
  }

  @Test
  func testIsValidTimeString_nonNumeric_single() {
    #expect(Time.isValidTimeString("abc") == false)
  }

  @Test
  func testIsValidTimeString_nonNumeric_firstComponent() {
    #expect(Time.isValidTimeString("abc:2") == false)
  }

  @Test
  func testIsValidTimeString_nonNumeric_secondComponent() {
    #expect(Time.isValidTimeString("1:abc") == false)
  }

  @Test
  func testIsValidTimeString_nonNumeric_thirdComponent() {
    #expect(Time.isValidTimeString("1:2:abc") == false)
  }

  @Test
  func testIsValidTimeString_emptyComponent_doubleColon() {
    #expect(Time.isValidTimeString("1::2") == false)
  }

  @Test
  func testIsValidTimeString_emptyComponent_leadingColon() {
    #expect(Time.isValidTimeString(":2") == false)
  }

  @Test
  func testIsValidTimeString_emptyComponent_trailingColon() {
    #expect(Time.isValidTimeString("1:") == false)
  }

  @Test
  func testIsValidTimeString_emptyComponent_trailingColonThree() {
    #expect(Time.isValidTimeString("1:2:") == false)
  }
}
