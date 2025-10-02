//
//  Untitled.swift
//  NextDream
//
//  Created by Jan on 15/05/2025.
//

import Foundation

extension Date{
    
    var custom: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d, yyyy - h:mm a"
            return formatter.string(from: self)
    }
    
    func convertToDayAndMonth() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-dd-MM"
        return dateFormatter.string(from: self)
    }
    
    func convertToStringFormat() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return dateFormatter.string(from: self)
    }
    
    func toMediumStyle() -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    
    func firstDate() -> Date{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func getDayName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: self)
    }
    
    func weekRange(_ numberOfDays: Int) -> String {
        let calendar = Calendar.current
        // Get the start and end of the week
        
        let endOfWeek = calendar.date(byAdding: .day, value: numberOfDays - 1, to: self) ?? self
        
        // Format day numbers (12, 17) and month name (February)
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        
        let startDay = dayFormatter.string(from: self)
        let endDay = dayFormatter.string(from: endOfWeek)
        let month = monthFormatter.string(from: self)
        
        if datesAreInDifferentMonth(self, endOfWeek){
            let endDayMonth = monthFormatter.string(from: endOfWeek)
            return "\(startDay) \(month) - \(endDay) \(endDayMonth)"
        }
        
        return "\(startDay) - \(endDay) \(month)"
    }
    
    func datesAreInDifferentMonth(_ firstDate: Date, _ secondDate: Date) -> Bool{
        let firstMonthIndex = Calendar.current.component(.month, from: firstDate)
        let secondMonthIndex = Calendar.current.component(.month, from: secondDate)
        
        return firstMonthIndex != secondMonthIndex
    }
    
    func showDate() -> String{
        let formatter = DateFormatter.myCustomStyle.string(from: self)
        let result: String = "\(formatter)"
        return result
    }
}
