//
//  Untitled.swift
//  NextDream
//
//  Created by Jan on 15/05/2025.
//

import Foundation

extension Date{
    
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
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: self)
    }
    
    func weekRange() -> String {
        let calendar = Calendar.current
        // Get the start and end of the week
        
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: self) ?? self
        
        // Format day numbers (12, 17) and month name (February)
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        
        let startDay = dayFormatter.string(from: self)
        let endDay = dayFormatter.string(from: weekEnd)
        let month = monthFormatter.string(from: self)
        
        return "\(startDay) - \(endDay) \(month)"
    }
}
