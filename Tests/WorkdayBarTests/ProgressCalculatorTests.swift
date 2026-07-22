import XCTest
@testable import WorkdayBar

final class ProgressCalculatorTests: XCTestCase {
    private let schedule = WorkdaySchedule(clockInHour: 9, clockInMinute: 0, clockOutHour: 18, clockOutMinute: 0)
    private let calendar = Calendar(identifier: .gregorian)

    private func date(hour: Int, minute: Int, weekday: Int = 2) -> Date {
        // 2024-01-01 is a Monday (weekday 2). Offset by (weekday - 2) days to hit other weekdays.
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 1 + (weekday - 2)
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components)!
    }

    func testProgressBeforeClockInIsZero() {
        let progress = ProgressCalculator.progress(now: date(hour: 8, minute: 0), schedule: schedule, calendar: calendar)
        XCTAssertEqual(progress, 0.0)
    }

    func testProgressAfterClockOutIsClampedToOne() {
        let progress = ProgressCalculator.progress(now: date(hour: 19, minute: 0), schedule: schedule, calendar: calendar)
        XCTAssertEqual(progress, 1.0)
    }

    func testProgressAtMidpoint() {
        // 9:00 -> 18:00 is 9 hours; 13:30 is 4.5 hours in, i.e. 0.5.
        let progress = ProgressCalculator.progress(now: date(hour: 13, minute: 30), schedule: schedule, calendar: calendar)
        XCTAssertEqual(progress, 0.5, accuracy: 0.0001)
    }

    func testProgressAtClockInIsZero() {
        let progress = ProgressCalculator.progress(now: date(hour: 9, minute: 0), schedule: schedule, calendar: calendar)
        XCTAssertEqual(progress, 0.0)
    }

    func testProgressAtClockOutIsOne() {
        let progress = ProgressCalculator.progress(now: date(hour: 18, minute: 0), schedule: schedule, calendar: calendar)
        XCTAssertEqual(progress, 1.0)
    }

    func testPhaseBeforeClockInCountsDownToStart() {
        // 07:00 -> 09:00 clock-in is 2 hours away.
        let phase = ProgressCalculator.phase(now: date(hour: 7, minute: 0), schedule: schedule, calendar: calendar)
        guard case .beforeStart(let remaining) = phase else {
            return XCTFail("expected .beforeStart, got \(phase)")
        }
        XCTAssertEqual(remaining, 2 * 3600, accuracy: 1)
        XCTAssertEqual(ProgressCalculator.statusText(for: phase), "교육 시작까지 2시 0분")
    }

    func testPhaseInProgressCountsDownToClockOut() {
        let phase = ProgressCalculator.phase(now: date(hour: 16, minute: 30), schedule: schedule, calendar: calendar)
        guard case .inProgress(let remaining) = phase else {
            return XCTFail("expected .inProgress, got \(phase)")
        }
        XCTAssertEqual(remaining, 90 * 60, accuracy: 1)
        XCTAssertEqual(ProgressCalculator.statusText(for: phase), "퇴근까지 1시간 30분")
    }

    func testPhaseAfterClockOutCountsElapsedOvertime() {
        // 19:30 is 1.5 hours after the 18:00 clock-out.
        let phase = ProgressCalculator.phase(now: date(hour: 19, minute: 30), schedule: schedule, calendar: calendar)
        guard case .afterEnd(let elapsed) = phase else {
            return XCTFail("expected .afterEnd, got \(phase)")
        }
        XCTAssertEqual(elapsed, 90 * 60, accuracy: 1)
        XCTAssertEqual(ProgressCalculator.statusText(for: phase), "추가공부 1시간 30분 하는 중")
    }

    func testPhaseResetsAtMidnightRegardlessOfPreviousDay() {
        // Just after midnight, "today's" clock-in (09:00) hasn't happened yet,
        // even though the previous day's clock-out was hours ago.
        let phase = ProgressCalculator.phase(now: date(hour: 0, minute: 5), schedule: schedule, calendar: calendar)
        guard case .beforeStart = phase else {
            return XCTFail("expected .beforeStart right after midnight, got \(phase)")
        }
    }

    func testIsWeekendDetectsSaturdayAndSunday() {
        XCTAssertTrue(ProgressCalculator.isWeekend(date: date(hour: 12, minute: 0, weekday: 7), calendar: calendar)) // Saturday
        XCTAssertTrue(ProgressCalculator.isWeekend(date: date(hour: 12, minute: 0, weekday: 1), calendar: calendar)) // Sunday
    }

    func testIsWeekendFalseOnWeekday() {
        XCTAssertFalse(ProgressCalculator.isWeekend(date: date(hour: 12, minute: 0, weekday: 2), calendar: calendar)) // Monday
    }
}
