//
//  Date+Extensions.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation

extension Date {
    // MARK: - Relative Time
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    // MARK: - Day Start
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    // MARK: - Day End
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    // MARK: - Is Today
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    // MARK: - Is Yesterday
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    // MARK: - Days Ago
    
    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }
    
    // MARK: - Days Between
    
    func daysBetween(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self.startOfDay, to: date.startOfDay)
        return abs(components.day ?? 0)
    }
    
    // MARK: - Format
    
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
