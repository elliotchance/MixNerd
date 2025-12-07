import Foundation
import Testing

@testable import MixNerd

struct TrackTimeEstimatorTests {
  let estimator = TrackTimeEstimator()

  func toTimes(_ times: [String]) -> [Time] {
    return times.map { Time(string: $0) }
  }

  @Test
  func testEstimate_allZeros() {
    let times = toTimes(["0:00", "0:00", "0:00"])
    let totalTime: TimeInterval = 3600.0
    let result = estimator.estimate(times: times, totalTime: totalTime)

    #expect(result.count == 3)
    #expect(result[0].description == "00:00")  // First track at 0:00 is correct, not estimated
    #expect(result[1].description == "~20:00")  // 3600 / 3 = 1200
    #expect(result[2].description == "~40:00")  // 3600 * 2 / 3 = 2400
  }

  @Test
  func testEstimate_allZeros_singleItem() {
    let times = toTimes(["0:00"])
    let totalTime: TimeInterval = 3600.0
    let result = estimator.estimate(times: times, totalTime: totalTime)

    #expect(result.count == 1)
    #expect(result[0].description == "00:00")  // First track at 0:00 is correct, not estimated
  }

  @Test
  func testEstimate_allKnownTimes() {
    let times = toTimes(["01:40", "05:00", "10:00"])
    let totalTime: TimeInterval = 3600.0
    let result = estimator.estimate(times: times, totalTime: totalTime)

    #expect(result.count == 3)
    #expect(result[0].description == "01:40")
    #expect(result[1].description == "05:00")
    #expect(result[2].description == "10:00")
  }

  @Test
  func testEstimate_leadingZeros() {
    let times = toTimes(["0:00", "0:00", "10:00"])
    let totalTime: TimeInterval = 3600.0
    let result = estimator.estimate(times: times, totalTime: totalTime)

    #expect(result.count == 3)
    #expect(result[0].description == "00:00")  // First track at 0:00 is correct, not estimated
    #expect(result[1].description == "~05:00")  // Halfway to first known time
    #expect(result[2].description == "10:00")
  }

  @Test
  func testEstimate_trailingZeros() {
    let times = toTimes(["01:40", "10:00", "0:00", "0:00"])
    let totalTime: TimeInterval = 1800.0  // 30 minutes
    let result = estimator.estimate(times: times, totalTime: totalTime)

    #expect(result.count == 4)
    #expect(result[0].description == "01:40")
    #expect(result[1].description == "10:00")
    // Trailing zeros: (1800 - 600) / 3 = 400 per step
    #expect(result[2].description == "~16:40")  // 600 + 400 = 1000
    #expect(result[3].description == "~23:20")  // 600 + 800 = 1400
  }

  @Test
  func testEstimate_zerosBetweenKnownTimes() {
    let times = toTimes(["01:40", "0:00", "0:00", "15:00"])
    let totalTime: TimeInterval = 3600.0
    let result = estimator.estimate(times: times, totalTime: totalTime)

    #expect(result.count == 4)
    #expect(result[0].description == "01:40")
    // Between 100 and 900: step = 800 / 3 = 266.666...
    #expect(result[1].description == "~06:06")  // 100 + 266.666... = 366.666...
    #expect(result[2].description == "~10:33")  // 100 + 533.333... = 633.333...
    #expect(result[3].description == "15:00")
  }

  @Test
  func testEstimate_mixedScenario() {
    let times = toTimes(["0:00", "0:00", "05:00", "0:00", "15:00", "0:00"])
    let totalTime: TimeInterval = 1800.0  // 30 minutes
    let result = estimator.estimate(times: times, totalTime: totalTime)

    #expect(result.count == 6)
    // First track at 0:00 is correct, not estimated
    #expect(result[0].description == "00:00")
    // Leading zeros: step = 300 / 2 = 150
    #expect(result[1].description == "~02:30")
    #expect(result[2].description == "05:00")
    // Between 300 and 900: step = 600 / 2 = 300
    #expect(result[3].description == "~10:00")  // 300 + 300
    #expect(result[4].description == "15:00")
    // Trailing: (1800 - 900) / 2 = 450
    #expect(result[5].description == "~22:30")  // 900 + 450 = 1350
  }

  @Test
  func testEstimate_allZeros_usesDefaultStep() {
    // When all zeros, distributes evenly: step = totalTime / count
    let times = toTimes(["0:00", "0:00"])
    let totalTime: TimeInterval = 3600.0
    let result = estimator.estimate(times: times, totalTime: totalTime)

    #expect(result.count == 2)
    #expect(result[0].description == "00:00")  // First track at 0:00 is correct, not estimated
    #expect(result[1].description == "~30:00")  // step = 3600 / 2 = 1800
  }
}
