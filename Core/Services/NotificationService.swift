//
//  NotificationService.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import UserNotifications
import Foundation

final class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    func scheduleDaily(at time: Date, enabled: Bool) {
        // Cancel existing notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
        
        guard enabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to learn!"
        content.body = "Keep your streak going! Learn some new words today."
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func scheduleStreakReminder(currentStreak: Int) {
        // Cancel existing streak reminder
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["streak_reminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "Don't lose your streak!"
        content.body = "You're on a \(currentStreak) day streak. Don't break it today!"
        content.sound = .default
        content.badge = 1
        
        // Schedule for 8 PM if user hasn't studied yet
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "streak_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule streak reminder: \(error)")
            }
        }
    }
    
    func notifyAchievementUnlocked(title: String, xp: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked!"
        content.body = "\(title) - +\(xp) XP"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func notifyLevelUp(level: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Level Up!"
        content.body = "Congratulations! You reached level \(level)!"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
