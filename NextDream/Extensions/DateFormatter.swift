//
//  DateFormatter.swift
//  NextDream
//
//  Created by Jan on 01/07/2025.
//

import Foundation

extension DateFormatter{
    static var myCustomStyle: DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy h:mm a"
        return formatter
    }
}
