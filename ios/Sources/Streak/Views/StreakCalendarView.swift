//
//  StreakCalendarView.swift
//  MyApp
//
//  Calendar view showing active days in the current month.
//

import SwiftUI

struct StreakCalendarView: View {
    @ObservedObject var streakProvider = StreakDataProvider.shared

    @State private var currentMonth: Date = Date()

    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }

                Spacer()

                Text(monthYearString)
                    .font(.headline)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                }
                .disabled(isCurrentMonth)
                .opacity(isCurrentMonth ? 0.3 : 1)
            }
            .padding(.horizontal)

            // Days of week header
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Empty cells for offset
                ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                    Text("")
                        .frame(width: 32, height: 32)
                }

                // Day cells
                ForEach(daysInMonth, id: \.self) { day in
                    DayCell(
                        day: day,
                        isActive: isActiveDay(day),
                        isToday: isToday(day),
                        isFuture: isFuture(day)
                    )
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    // MARK: - Calendar Calculations

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    private var isCurrentMonth: Bool {
        calendar.isDate(currentMonth, equalTo: Date(), toGranularity: .month)
    }

    private var firstDayOfMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
    }

    private var firstWeekdayOffset: Int {
        calendar.component(.weekday, from: firstDayOfMonth) - 1
    }

    private var daysInMonth: [Int] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        return Array(range)
    }

    private func isActiveDay(_ day: Int) -> Bool {
        guard let date = dateForDay(day) else { return false }
        return streakProvider.streakData.activeDays.contains { activeDay in
            calendar.isDate(activeDay, inSameDayAs: date)
        }
    }

    private func isToday(_ day: Int) -> Bool {
        guard let date = dateForDay(day) else { return false }
        return calendar.isDateInToday(date)
    }

    private func isFuture(_ day: Int) -> Bool {
        guard let date = dateForDay(day) else { return false }
        return date > Date()
    }

    private func dateForDay(_ day: Int) -> Date? {
        var components = calendar.dateComponents([.year, .month], from: currentMonth)
        components.day = day
        return calendar.date(from: components)
    }

    // MARK: - Navigation

    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    private func nextMonth() {
        guard !isCurrentMonth else { return }
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

// MARK: - Day Cell

private struct DayCell: View {
    let day: Int
    let isActive: Bool
    let isToday: Bool
    let isFuture: Bool

    var body: some View {
        ZStack {
            if isActive {
                Circle()
                    .fill(Color.orange)
            } else if isToday {
                Circle()
                    .stroke(Color.orange, lineWidth: 2)
            }

            Text("\(day)")
                .font(.subheadline)
                .foregroundColor(textColor)
        }
        .frame(width: 32, height: 32)
    }

    private var textColor: Color {
        if isActive {
            return .white
        } else if isFuture {
            return .secondary.opacity(0.5)
        } else {
            return .primary
        }
    }
}

#Preview {
    StreakCalendarView()
        .padding()
}
