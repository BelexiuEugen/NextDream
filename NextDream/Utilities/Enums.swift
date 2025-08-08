//
//  Enums.swift
//  NextDream
//
//  Created by Jan on 13/05/2025.
//

import Foundation
import SwiftUI

//MARK: Export Type

enum ExportType: String, CaseIterable{
    case JSON
    case CSV
    case PDF
    case JPG
}

enum ErrorType{
    
}

enum symbolName{
    
}

//MARK: Notification

//let content = UNMutableNotificationContent()
//content.title = "Important Reminder!"
//content.subtitle = "Time to check your app"
//content.body = "Don't forget to take a look at your scheduled tasks."
//content.sound = UNNotificationSound.default // Use default notification sound

enum Notification: String{
    case title = "Daily Reminder"
    case subtitle = "Time to complete tasks 🔥"
    case body = "You have 10 task to complete today"
    
    static var notificationSound: UNNotificationSound {
        return .default
    }
}

//MARK: Elements

enum ElementStreak{
    case streak, todayTaskAchieved, totalTaskAchieved
    
    var image: Image{
        switch self {
        case .streak:
            return Image(systemName: "flame.fill")
        case .todayTaskAchieved:
            return Image(systemName: "target")
        case .totalTaskAchieved:
            return Image(systemName: "trophy.fill")
        }
    }
    
    var name: Text{
        switch self {
        case .streak:
            return Text("Streak")
        case .todayTaskAchieved:
            return Text("Today Task Achieved")
        case .totalTaskAchieved:
            return Text("Total Task Achieved")
        }
    }
    
    var color: Color {
          switch self {
          case .streak:
              return .orange
          case .todayTaskAchieved:
              return .blue
          case .totalTaskAchieved:
              return .green
          }
      }
}

// MARK: Settings Enum

enum Theme: String, CaseIterable{
    case light = "light"
    case dark = "dark"
//    case custom = "custom"
}

enum FontSize: String, CaseIterable{
    case largeTitle = "Extremly Big"
    case title2 = "Big"
    case headline = "Normal"
    case body = "Small"
}

enum Weekday: String, CaseIterable, Codable {
    
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    
    var index: Int {
        switch self {
        case .sunday:
            1
        case .monday:
            2
        case .tuesday:
            3
        case .wednesday:
            4
        case .thursday:
            5
        case .friday:
            6
        case .saturday:
            7
        }
    }
}

extension Weekday {
    static func from(date: Date, calendar: Calendar = .current) -> Weekday? {
        let weekdayIndex = calendar.component(.weekday, from: date)
        
        // Map system weekday index to your enum
        // Calendar weekday: 1 = Sunday, 2 = Monday, ..., 7 = Saturday
        switch weekdayIndex {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return nil
        }
    }
}
