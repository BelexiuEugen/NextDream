//
//  UserSettingsViewModel.swift
//  NextDream
//
//  Created by Jan on 07/07/2025.
//

import Foundation

//static let notification = "notification"
//static let areNotificationEnabled = "areNotificationEnabled"
//static let isReminderEnabled = "isReminderEnabled"

@Observable
final class UserSettingsViewModel{
    
    var notification: Bool = false
//    private var _autoReschedule = false
    var autoReschedule: Bool = false
    var selectedTheme: Theme = .light;
    var selectedFontSize: FontSize = .body;
    private var _autoRescheduleTime: Date = .now
    var autoRescheduleTime: Date{
        get { _autoRescheduleTime }
        set { scheduleNotification(date: newValue) }
    }
    var notificationManager = NotificationManager()
    
    private func scheduleNotification(date: Date){
        Task{
            guard await checkPermissionForNotification() else {
                return
            }
            
            await addScheduledNotification(date: date)
        }
    }
    
    private func addScheduledNotification(date: Date) async {
        
        do{
            let identifier = try await notificationManager.scheduleLocalNotification(date: date)
            UserDefaults().set(identifier, forKey: UserDefaultsKeys.notificationIdentifier)
        } catch{
            
        }
    }
    
    private func updateNotificationStatus() async{
        guard await checkPermissionForNotification() else{
            return
        }
        
        notification.toggle()  // or better, assign explicitly
    }
    
    private func checkPermissionForNotification() async -> Bool{
        let key = UserDefaultsKeys.areNotificationEnabled
        
        if !UserDefaults.standard.bool(forKey: key) {
            
            guard await askPermissionForNotification() else{
                return false
            }
            
            UserDefaults.standard.set(true, forKey: key)
        }
        
        return true
    }
    
    private func askPermissionForNotification() async -> Bool{
        
        var result: Bool = false
        
        do{
            result = try await notificationManager.requestNotificationPermission()
        }
        catch{
            print("Add a error in here please \(error.localizedDescription)")
        }
        
        return result
    }
}
