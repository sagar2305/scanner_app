//
//  NotificationHelper.swift
//  Document Scanner
//
//  Created by Revathi on 04/07/22.
//

import Foundation
import UserNotifications

class NotificationHelper {
    
    static let shared = NotificationHelper()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                    print("Permission granted: \(granted)")
                    guard granted else { return }
                    self?.getNotificationSettings()
                }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
          guard settings.authorizationStatus == .authorized else { return }
      }
    }
    
    func removeScheduledNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        AnalyticsHelper.shared.logEvent(.removedScheduledNotifications)
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Upgrade to Premium"
        content.body = "Click, Scan, Store, and Share your document with all the apps among your peer and friend."
        content.sound = .default
        content.userInfo = ["value": "Data with local notification"]
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60 * 48, repeats: true)
        let request = UNNotificationRequest(
            identifier: "reminder",
            content: content,
            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error)
            }
        }
        AnalyticsHelper.shared.logEvent(.scheduledLocalNotification)
    }
    
    func scheduleNotificationAfterUserCancelledPurchase() {
        let content = UNMutableNotificationContent()
        content.title = "Subscribe Now"
        content.body = "Subscribe to enjoy all the useful benefits of the app."
        content.sound = .default
        content.userInfo = ["value": "Data with local notification"]
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "cancelled purchase",
            content: content,
            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error)
            }
        }
        AnalyticsHelper.shared.logEvent(.pushNotificationAfterUserCancelledPurchase)
    }
}
