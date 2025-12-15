import Foundation

// MARK: - SleepRecord Model

/// Represents a single sleep event with start time, duration, and reason
struct SleepRecord: Identifiable {
    let id = UUID()
    let startTime: Date
    let duration: TimeInterval // in seconds
    let reason: String

    var endTime: Date {
        startTime.addingTimeInterval(duration)
    }

    var durationString: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(
                format: NSLocalizedString("duration.hours_minutes", comment: ""),
                hours,
                minutes,
            )
        } else if minutes > 0 {
            return String(
                format: NSLocalizedString("duration.minutes_seconds", comment: ""),
                minutes,
                seconds,
            )
        } else {
            return String(format: NSLocalizedString("duration.seconds", comment: ""), seconds)
        }
    }
}
