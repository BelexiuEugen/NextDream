//
//  UserSettingsViewModel.swift
//  NextDream
//
//  Created by Jan on 07/07/2025.
//

import Foundation
import SwiftUI
import SwiftData

//static let notification = "notification"
//static let areNotificationEnabled = "areNotificationEnabled"
//static let isReminderEnabled = "isReminderEnabled"


@Observable
final class UserSettingsViewModel{
    
    var notification: Bool = defaults.bool(forKey: UserDefaultsKeys.areNotificationEnabled)
    var autoReschedule: Bool = defaults.string(forKey: UserDefaultsKeys.notificationIdentifier) != nil
    var didChangedRescheduleTime = false
    var selectedTheme: Theme = .light;
    var selectedFontSize: FontSize = .body;
    var autoRescheduleTime: Date = .now
    var notificationManager = NotificationManager()
    var queryDescriptorManager = QueryDescriptorManager()
    var defaultTaskRepository: DefaultTaskRepository
    var chartData: [(TaskCategory, Int)] = []
    var total: Double = 0.0

    var angles: [Angle] {
        var currentAngle = Angle(degrees: 0)
        var result: [Angle] = []
        
        for category in chartData{
            let angle = Angle(degrees: (Double(category.1) / total) * 360)
            result.append(currentAngle)
            currentAngle += angle
        }
        result.append(currentAngle)
        return result
    }
    
    init(modelContext: ModelContext){
        defaultTaskRepository = DefaultTaskRepository(modelContext: modelContext)
        fetchTaskForChart()
    }
    
    func calculateTotal() -> Double {
        var result = 0.0
        for value in chartData {
            result += Double(value.1)
        }
        return result
    }
    
    func fetchTaskForChart() {
        let descriptor = queryDescriptorManager.descriptorForMainTasks()
        chartData = defaultTaskRepository.fetchTasksForStatistics(descriptor: descriptor)
        total = calculateTotal()
    }
    
    func saveData() async{
        
        defaults.set(_notification, forKey: UserDefaultsKeys.areNotificationEnabled)
        
        guard autoReschedule, notification else {
            deleteUserDefaults()
            return
        }
        
        guard
            let storedDate = defaults.object(forKey: UserDefaultsKeys.notificationScheduledDate) as? Date,
            let identifier = defaults.string(forKey: UserDefaultsKeys.notificationIdentifier) else {
            await saveUserDefaults()
            return
        }
        
        guard !isSameClockTime(userSavedDate: storedDate) else { return }
        
        notificationManager.deleteNotification(identifier: identifier)
        await saveUserDefaults()
        
    }
    
    private func saveUserDefaults() async {
        await addScheduledNotification()
        defaults.set(autoRescheduleTime, forKey: UserDefaultsKeys.notificationScheduledDate)
    }
    
    // Save Data
    private func deleteUserDefaults(){
        if let identifier = defaults.string(forKey: UserDefaultsKeys.notificationIdentifier) {
            notificationManager.deleteNotification(identifier: identifier)
            defaults.removeObject(forKey: UserDefaultsKeys.notificationScheduledDate)
            defaults.removeObject(forKey: UserDefaultsKeys.notificationIdentifier)
        }
    }
    
    // Save Data
    private func isSameClockTime(userSavedDate: Date) -> Bool{
        let calendar = Calendar.current
        
        let firstDate = calendar.dateComponents([.hour, .minute], from: userSavedDate)
        let secondDate = calendar.dateComponents([.hour, .minute], from: autoRescheduleTime)
        
        print(firstDate.hour == secondDate.hour && firstDate.hour == secondDate.hour)
        
        return firstDate.hour == secondDate.hour && firstDate.minute == secondDate.minute
    }
    
    private func addScheduledNotification() async {
        
        do{
            print(autoRescheduleTime)
            let identifier = try await notificationManager.scheduleLocalNotification(date: autoRescheduleTime)
            defaults.set(identifier, forKey: UserDefaultsKeys.notificationIdentifier)
        } catch{
            print("Add a error in here.")
        }
    }
    
    func updateNotificationStatus() async{
    guard await checkPermissionForNotification() else{
        notification = false
        return
    }
    
//    notification.toggle()  // or better, assign explicitly
}
    
    private func checkPermissionForNotification() async -> Bool{
        let key = UserDefaultsKeys.areNotificationEnabled
        
        if !UserDefaults.standard.bool(forKey: key) {
            
            guard await askPermissionForNotification() else{
                notification = false
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

//MARK: Unused functions.

extension UserSettingsViewModel{
    func deleteAllNotification(){
        notificationManager.deleteAllNotification()
    }
}

