//
//  Enums.swift
//  NextDream
//
//  Created by Jan on 13/05/2025.
//

import Foundation
import SwiftUI

//MARK: Task Model
enum TaskPriority: String, Codable, CaseIterable{
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

enum TaskType: String, Codable, CaseIterable{
    case day = "Day Task"
    case week = "Week Task"
    case month = "Month Task"
    case year = "Year Task"
    case custom = "Custom Task"
    case byDate = "By Date"
}

enum TaskCategory: String, Codable, CaseIterable{
    case work = "Work"
    case personal = "Personal"
    case health = "Health"
    case finance = "Finance"
    case education = "Education"
    case hobbies = "Hobbies"
}

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

//MARK: Streak Elements

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

//MARK: Task Creation

enum Weekday: Int, CaseIterable, Codable {
    
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var dayName: String{
        switch self {
        case .sunday:
            "Sunday"
        case .monday:
            "Monday"
        case .tuesday:
            "Tuesday"
        case .wednesday:
            "Wednesday"
        case .thursday:
            "Thursday"
        case .friday:
            "Friday"
        case .saturday:
            "Saturday"
        }
    }
    
    init?(date: Date, calendar: Calendar = .current){
        let weekdayIndex = calendar.component(.weekday, from: date)
        guard let weekday = Weekday(rawValue: weekdayIndex) else { return nil }
        self = weekday
    }
    
    mutating func next(){
        guard let weekday = Weekday(rawValue: self.rawValue % 7 + 1) else { return }
        
        self = weekday
    }
    
    func calculateDaysCount(from date: Date, calendar: Calendar = .current) -> Int{
        let weekdayIndex = calendar.component(.weekday, from: date)
        let userWeekDayIndex = self.rawValue
        
        guard weekdayIndex != userWeekDayIndex else { return 7}
        
        return userWeekDayIndex > weekdayIndex ? userWeekDayIndex - weekdayIndex : 7 - weekdayIndex + userWeekDayIndex
    }
}

enum Months: Int{
    case january = 1
    case february = 2
    case march = 3
    case april = 4
    case may = 5
    case june = 6
    case july = 7
    case august = 8
    case september = 9
    case october = 10
    case november = 11
    case december = 12
    
    var monthName: String{
        switch self {
        case .january:
            "January"
        case .february:
            "February"
        case .march:
            "March"
        case .april:
            "April"
        case .may:
            "May"
        case .june:
            "June"
        case .july:
            "July"
        case .august:
            "August"
        case .september:
            "September"
        case .october:
            "October"
        case .november:
            "November"
        case .december:
            "December"
        }
    }
    
    init(date: Date, calendar: Calendar = .current) {
        let monthIndex = calendar.component(.month, from: date)
        
        self = Months(rawValue: monthIndex) ?? .january
    }
    
    mutating func next(){
        guard let month = Months(rawValue: self.rawValue % 12 + 1) else { return }
        
        self = month
    }
    
    func calculateDaysCount(date: Date) -> Int{
        switch self {
        case .january, .march, .may, .july, .august, .october, .december:
            return 31
        case .april, .june, .september, .november:
            return 30
        default:
            return februaryDayCount(startDate: date)
        }
    }
    
    func februaryDayCount(startDate: Date) -> Int{
        let currentYear = Calendar.current.component(.year, from: startDate)
        
        return Months.isLeapYear(currentYear) ? 29 : 28
    }
    
    static func isLeapYear(_ year: Int) -> Bool{
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }
}

//MARK: TaskCreationViewModel

enum CreationModelType: String, CaseIterable{
    case regular
    case calendar
}
