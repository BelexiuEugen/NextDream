//
//  NotificationManager.swift
//  NextDream
//
//  Created by Jan on 07/07/2025.
//

import Foundation
import UserNotifications

class NotificationManager{
    
    func requestNotificationPermission() async throws -> Bool{
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }
    
    func scheduleLocalNotification(date: Date) async throws -> String{
        
        let content = createNotificationCotent()
        let dateComponents = createDateComponent(date: date)
        
        print(date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await UNUserNotificationCenter.current().add(request)
        
        return identifier
    }
    
    private func createNotificationCotent() -> UNMutableNotificationContent{
        let content = UNMutableNotificationContent()
        content.title = Notification.title.rawValue
        content.subtitle = Notification.subtitle.rawValue
        content.body = Notification.body.rawValue
        content.sound = Notification.notificationSound
        
        return content
    }
    
    private func createDateComponent(date: Date) -> DateComponents{
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.hour =  calendar.component(.hour, from: date)
        dateComponents.minute = calendar.component(.minute, from: date)
        
        return dateComponents
    }
}
