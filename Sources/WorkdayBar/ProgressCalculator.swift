import Foundation

struct WorkdaySchedule {
    var clockInHour: Int
    var clockInMinute: Int
    var clockOutHour: Int
    var clockOutMinute: Int
}

enum ProgressCalculator {
    static func progress(now: Date, schedule: WorkdaySchedule, calendar: Calendar = .current) -> Double {
        let clockIn = time(on: now, hour: schedule.clockInHour, minute: schedule.clockInMinute, calendar: calendar)
        let clockOut = time(on: now, hour: schedule.clockOutHour, minute: schedule.clockOutMinute, calendar: calendar)
        guard clockOut > clockIn else { return 0 }

        if now <= clockIn { return 0 }
        if now >= clockOut { return 1 }

        let total = clockOut.timeIntervalSince(clockIn)
        let elapsed = now.timeIntervalSince(clockIn)
        return min(max(elapsed / total, 0), 1)
    }

    static func isWeekend(date: Date, calendar: Calendar = .current) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }

    /// The three states of a workday, always computed against *today's*
    /// clock-in/out (see `time(on:hour:minute:calendar:)`), so the phase
    /// naturally resets at midnight without any persisted state.
    enum Phase: Equatable {
        case beforeStart(remaining: TimeInterval)
        case inProgress(remaining: TimeInterval)
        case afterEnd(elapsed: TimeInterval)
    }

    static func phase(now: Date, schedule: WorkdaySchedule, calendar: Calendar = .current) -> Phase {
        let clockIn = time(on: now, hour: schedule.clockInHour, minute: schedule.clockInMinute, calendar: calendar)
        let clockOut = time(on: now, hour: schedule.clockOutHour, minute: schedule.clockOutMinute, calendar: calendar)

        if now < clockIn {
            return .beforeStart(remaining: clockIn.timeIntervalSince(now))
        } else if now < clockOut {
            return .inProgress(remaining: clockOut.timeIntervalSince(now))
        } else {
            return .afterEnd(elapsed: now.timeIntervalSince(clockOut))
        }
    }

    static func statusText(for phase: Phase) -> String {
        switch phase {
        case .beforeStart(let remaining):
            return "교육 시작까지 \(formatDuration(remaining, hourUnit: "시"))"
        case .inProgress(let remaining):
            return "퇴근까지 \(formatDuration(remaining, hourUnit: "시간"))"
        case .afterEnd(let elapsed):
            return "추가공부 \(formatDuration(elapsed, hourUnit: "시간")) 하는 중"
        }
    }

    private static func formatDuration(_ interval: TimeInterval, hourUnit: String) -> String {
        let totalMinutes = Int(interval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours)\(hourUnit) \(minutes)분"
    }

    private static func time(on date: Date, hour: Int, minute: Int, calendar: Calendar) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }
}
