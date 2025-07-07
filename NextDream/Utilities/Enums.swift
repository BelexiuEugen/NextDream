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
