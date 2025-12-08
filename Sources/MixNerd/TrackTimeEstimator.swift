import Foundation

class TrackTimeEstimator {
  func estimate(times: [Time], totalTime: TimeInterval) -> [Time] {
    guard !times.isEmpty else {
      return times
    }

    var result = times

    // Find all known (non-zero) times with their indices
    // Also treat the first track at 0:00 as a known time (it's the correct start time)
    let knownTimes = times.enumerated().compactMap { index, time -> (Int, TimeInterval)? in
      if index == 0 && time.at == 0 {
        return (0, 0.0)
      }
      guard time.at > 0 && !time.isEstimated else {
        return nil
      }
      return (index, time.at)
    }

    // If no known times, distribute evenly across totalTime
    if knownTimes.isEmpty {
      let step = times.count > 0 ? totalTime / Double(times.count) : 0.0
      for index in result.indices {
        result[index] = Time(estimatedAt: step.isFinite ? Double(index) * step : 0.0)
      }
      return result
    }

    // Estimate leading zeros (before first known time)
    if let firstKnown = knownTimes.first, firstKnown.0 > 0 {
      let gapCount = firstKnown.0
      let span = max(firstKnown.1, 0)
      let initialStep = gapCount > 0 ? (gapCount > 1 ? span / Double(gapCount) : span) : 0.0
      let step = initialStep > 0 ? initialStep : 60.0

      for offset in 0..<gapCount {
        let index = offset
        if result[index].at == 0 || result[index].isEstimated {
          result[index] = Time(estimatedAt: Double(offset) * step)
        }
      }
    }

    // Estimate zeros between known times
    for (left, right) in zip(knownTimes, knownTimes.dropFirst()) {
      let gapCount = right.0 - left.0 - 1
      guard gapCount > 0 else {
        continue
      }

      let span = right.1 - left.1
      let step = span > 0 ? span / Double(gapCount + 1) : 60.0

      for offset in 1...gapCount {
        let index = left.0 + offset
        if result[index].at == 0 || result[index].isEstimated {
          result[index] = Time(estimatedAt: left.1 + step * Double(offset))
        }
      }
    }

    // Estimate trailing zeros (after last known time)
    if let lastKnown = knownTimes.last {
      let remaining = times.count - lastKnown.0 - 1
      if remaining > 0 {
        let span = max(totalTime - lastKnown.1, 0)
        let step = span > 0 ? span / Double(remaining + 1) : 60.0

        for offset in 1...remaining {
          let index = lastKnown.0 + offset
          if result[index].at == 0 || result[index].isEstimated {
            result[index] = Time(estimatedAt: lastKnown.1 + step * Double(offset))
          }
        }
      }
    }

    // If the first time is 0, it's always treated as exact.
    if let first = result.first, first.at == 0 {
      result[0] = Time(at: 0.0)
    }

    return result
  }
}
