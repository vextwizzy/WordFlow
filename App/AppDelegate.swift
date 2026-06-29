//
//  AppDelegate.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        registerForPushNotifications(application)
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        // Send token to your server if needed
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    private func registerForPushNotifications(_ application: UIApplication) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
}
